#root = File.join(File.dirname(__FILE__), "..")
#$LOAD_PATH.push root unless $LOAD_PATH.include? root

require File.join(File.dirname(__FILE__), "worker")

require "providers/provider_factory"
require "commands/server"
require "db/mongo/models/server"
require "db/mongo/models/report"

class CreateServerWorker < Worker
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
        "type" => Report::SERVER_TYPE
      }
      mongo.save_report(Report.new(o))

      status = create_server_proc.call(out, s, provider, mongo)
      status
    end
  end
end
