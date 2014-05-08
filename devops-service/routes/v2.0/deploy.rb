require "commands/knife_commands"
require "routes/v2.0/base_routes"
require "providers/provider_factory"
require "commands/deploy"
require "commands/status"

module Version2_0
  class DeployRoutes < BaseRoutes

    include DeployCommands
    include StatusCommands

    def initialize wrapper
      super wrapper
      puts "Deploy routes initialized"
    end

    after "/deploy" do
      statistic
    end

    # Run chef-client on some instances
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "names": [], -> array of servers names to run chef-client
    #       "tags": []   -> array of tags to apply on each server before running chef-client
    #     }
    #
    # * *Returns* : text stream
    post "/deploy" do
      check_headers :content_type
      check_privileges("server", "w")
      r = create_object_from_json_body
      names = check_array(r["names"], "Parameter 'names' should be a not empty array of strings")
      tags = check_array(r["tags"], "Parameter 'tags' should be an array of strings", String, true) || []

      servers = BaseRoutes.mongo.servers_by_names(names)
      halt(404, "No servers found for names '#{names.join("', '")}'") if servers.empty?
      keys = {}
      servers.sort_by!{|s| names.index(s.chef_node_name)}
      stream() do |out|
        status = []
        servers.each do |s|
          begin

            begin
              BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
            rescue InvalidPrivileges, RecordNotFound  => e
              out << e.message + "\n"
              status.push 2
              next
            end

            old_tags_str = nil
            new_tags_str = nil
            unless tags.empty?
              old_tags_str = KnifeCommands.tags_list(s.chef_node_name).join(" ")
              out << "Server tags: #{old_tags_str}\n"
              KnifeCommands.tags_delete(s.chef_node_name, old_tags_str)

              new_tags_str = tags.join(" ")
              out << "Server new tags: #{new_tags_str}\n"
              cmd = KnifeCommands.tags_create(s.chef_node_name, new_tags_str)
              unless cmd[1]
                m = "Error: Cannot add tags '#{new_tags_str}' to server '#{s.chef_node_name}'"
                logger.error(m)
                out << m + "\n"
                status.push 3
                next
              end
              logger.info("Set tags for '#{s.chef_node_name}': #{new_tags_str}")
            end

            unless keys.key? s.key
              k = BaseRoutes.mongo.key s.key
              keys[s.key] = k.path
            end
            status.push(deploy_server out, s, keys[s.key])

            unless tags.empty?
              out << "Restore tags\n"
              cmd = KnifeCommands.tags_delete(s.chef_node_name, new_tags_str)
              logger.info("Deleted tags for #{s.chef_node_name}: #{new_tags_str}")
              cmd = KnifeCommands.tags_create(s.chef_node_name, old_tags_str)
              logger.info("Set tags for #{s.chef_node_name}: #{old_tags_str}")
            end
            out << create_status(status)
          rescue IOError => e
            logger.error e.message
            break
          end
        end
      end
    end

  end
end
