require "commands/knife_commands"
require "commands/ssh"

module DeployCommands

  def deploy_server_proc
    lambda do |out, s, mongo, tags|
      begin
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
            return 3
          end
          logger.info("Set tags for '#{s.chef_node_name}': #{new_tags_str}")
        end

        k = mongo.key s.key
        r = deploy_server out, s, k.path

        unless tags.empty?
          out << "Restore tags\n"
          cmd = KnifeCommands.tags_delete(s.chef_node_name, new_tags_str)
          logger.info("Deleted tags for #{s.chef_node_name}: #{new_tags_str}")
          cmd = KnifeCommands.tags_create(s.chef_node_name, old_tags_str)
          logger.info("Set tags for #{s.chef_node_name}: #{old_tags_str}")
        end
        return r
      rescue IOError => e
        logger.error e.message
        return 4
      end
    end
  end

  def deploy_server out, server, cert_path
    out << "\nRun chef-client on '#{server.chef_node_name}'\n"
    cmd = "chef-client"
    ip = if server.public_ip.nil?
      server.private_ip
    else
      out << "Public IP detected\n"
      server.public_ip
    end
    out.flush if out.respond_to?(:flush)
    lline = KnifeCommands.ssh_stream(out, cmd, ip, server.remote_user, cert_path)
    r = /Chef\sClient\sfinished/i
    return (lline[r].nil? ? 1 : 0)
  end

end
