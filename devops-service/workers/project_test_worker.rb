require File.join(File.dirname(__FILE__), "worker")

require "providers/provider_factory"
require "commands/server"
require "db/mongo/models/server"
require "json"
require "fileutils"
require "commands/status"
require "db/mongo/models/report"

class ProjectTestWorker < Worker
  include ServerCommands
  include StatusCommands

  def perform(dir, params, conf)
    call(conf, nil, dir) do |mongo, provider, out, file|
      logger.info "Test project '#{params["project"]}' and env '#{params["env"]}' (user - #{params["user"]})"
      project = mongo.project(params["project"])
      env = project.deploy_env(params["env"])
      user = params["user"]
      o = {
        "file" => file,
        "_id" => jid,
        "created_by" => user,
        "project" => params["project"],
        "deploy_env" => params["env"],
        "type" => Report::PROJECT_TEST_TYPE
      }
      mongo.save_report(Report.new(o))

      provider = ::Provider::ProviderFactory.get(env.provider)
      servers = extract_servers(provider, project, env, {}, user, mongo)
      result = {:servers => []}
      project.deploy_envs = [ env ]
      result[:project] = project.to_hash
      status = 0
      servers.each do |s|
        sr = {}
        t1 = Time.now
        out << "\n=== Create server ===\n"
        out.flush
        if provider.create_server(s, out)
          out << "\n=== Create server - OK ===\n"
          out.flush
          t2 = Time.now
          sr[:id] = s.id
          sr[:create] = {:status => true}
          sr[:create][:time] = time_diff_s(t1, t2)
          s.chef_node_name = provider.create_default_chef_node_name(s)
          logger.info "Server with parameters: #{s.to_hash.inspect} is running"
          key = mongo.key(s.key)
          out << "\n=== Bootstrap ===\n"
          out.flush
          r = bootstrap(s, out, key.path, logger)
          t1 = Time.now
          sr[:chef_node_name] = s.chef_node_name
          if r == 0
            out << "\n=== Bootstrap - OK ===\n"
            out.flush
            sr[:bootstrap] = {:status => true}
            sr[:bootstrap][:time] = time_diff_s(t2, t1)
            logger.info "Server with id '#{s.id}' is bootstraped"
            out << "\n=== Check server ===\n"
            out.flush
            if check_server(s)
              mongo.server_insert s
              out << "\n=== OK, server has been inserted ===\n"
              out.flush
            end
          else
            status = 2
            out << "\n=== Bootstrap - FAIL ===\n"
            out.flush
            sr[:bootstrap] = {:status => false}
            sr[:bootstrap][:return_code] = r
          end

          t1 = Time.now
          out << "\n=== Delete server ===\n"
          out.flush
          r = delete_from_chef_server(s.chef_node_name)
          begin
            r[:server] = provider.delete_server s
            out << "\n=== Delete server - OK ===\n"
            out.flush
          rescue Fog::Compute::OpenStack::NotFound, Fog::Compute::AWS::Error
            status = 3
            out << "\n=== Delete server - FAIL ===\n"
            out.flush
            r[:server] = "Server with id '#{s.id}' not found in '#{provider.name}' servers"
            logger.warn r[:server]
          end
          mongo.server_delete s.id
          t2 = Time.now
          sr[:delete] = {:status => true}
          sr[:delete][:time] = time_diff_s(t1, t2)
        else
          status = 1
          out << "\n=== Create server - FAIL ===\n"
          out.flush
          sr[:create] = {:status => false}
        end
        result[:servers].push sr
      end
      out << "\n\n#{result.to_json}"
      status
    end
  end
end
