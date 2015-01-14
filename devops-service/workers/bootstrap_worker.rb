#root = File.join(File.dirname(__FILE__), "..")
#$LOAD_PATH.push root unless $LOAD_PATH.include? root

require File.join(File.dirname(__FILE__), "worker")

require "providers/provider_factory"
require "commands/server"
require "db/mongo/models/server"
require "db/mongo/models/report"

class BootstrapWorker < Worker
  include ServerCommands

  def perform(dir, e_provider, server, owner, conf)
    call(conf, e_provider, dir) do |mongo, provider, out, file|
      s = Server.new(server)
      s.options = convert_config(server["options"])
      o = {
        "file" => file,
        "_id" => jid,
        "created_by" => owner,
        "project" => s.project,
        "deploy_env" => s.deploy_env,
        "type" => Report::BOOTSTRAP_TYPE
      }
      mongo.save_report(Report.new(o))

      key = mongo.key(s.key)
      out << "\nBootstrap with run list: #{s.options[:run_list].inspect}"
      status = bootstrap(s, out, key.path, logger)
      if status == 0
        out << "Chef node name: #{s.chef_node_name}\n"
        mongo.server_set_chef_node_name s
        out << "Chef node name has been updated\n"
      end
      status
    end
  end
end

