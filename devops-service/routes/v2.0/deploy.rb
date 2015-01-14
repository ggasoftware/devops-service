require "commands/knife_commands"
require "routes/v2.0/base_routes"
require "providers/provider_factory"
require "commands/deploy"
require "commands/status"
require "workers/deploy_worker"

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

    # Run chef-client on reserved server
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "names": [],  -> array of servers names to run chef-client
    #       "tags": [],   -> array of tags to apply on each server before running chef-client
    #       "trace": true -> return output in stream
    #     }
    #
    # * *Returns* : text stream
    post "/deploy" do
      check_headers :content_type
      check_privileges("server", "x")
      r = create_object_from_json_body
      names = check_array(r["names"], "Parameter 'names' should be a not empty array of strings")
      tags = check_array(r["tags"], "Parameter 'tags' should be an array of strings", String, true) || []

      servers = BaseRoutes.mongo.servers(nil, nil, names, true)
      halt(404, "No reserved servers found for names '#{names.join("', '")}'") if servers.empty?
      keys = {}
      servers.sort_by!{|s| names.index(s.chef_node_name)}
      if r.key?("trace")
        stream() do |out|
          status = []
          begin
            servers.each do |s|
              project = begin
                BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
              rescue InvalidPrivileges, RecordNotFound  => e
                out << e.message + "\n"
                status.push 2
                next
              end
              res = deploy_server_proc.call(out, s, BaseRoutes.mongo, tags)
              status.push(res)
            end
            out << create_status(status)
          rescue IOError => e
            logger.error e.message
            break
          end
        end # stream
      else
        dir = DevopsService.config[:report_dir_v2]
        files = []
        uri = URI.parse(request.url)
        servers.each do |s|
          project = begin
            BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
          rescue InvalidPrivileges, RecordNotFound  => e
            next
          end
          jid = DeployWorker.perform_async(dir, s.to_hash, tags, request.env['REMOTE_USER'], DevopsService.config)
          logger.info "Job '#{jid}' has been started"
          uri.path = "#{DevopsService.config[:url_prefix]}/v2.0/report/" + jid
          files.push uri.to_s
        end
        sleep 1
        json files
      end
    end

  end
end
