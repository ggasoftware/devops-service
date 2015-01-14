#root = File.join(File.dirname(__FILE__), "..")
#$LOAD_PATH.push root unless $LOAD_PATH.include? root

require File.join(File.dirname(__FILE__), "worker")

require "commands/deploy"
require "db/mongo/models/server"
require "db/mongo/models/report"

class DeployWorker < Worker
  include DeployCommands

  def perform(dir, server, tags, owner, conf)
    call(conf, nil, dir) do |mongo, provider, out, file|
      s = Server.new(server)
      o = {
        "file" => file,
        "_id" => jid,
        "created_by" => owner,
        "project" => s.project,
        "deploy_env" => s.deploy_env,
        "type" => Report::DEPLOY_TYPE
      }
      mongo.save_report(Report.new(o))

      status = deploy_server_proc.call(out, s, mongo, tags)
      status
    end
  end
end
