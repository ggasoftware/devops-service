require "json"
require "chef"
require "commands/knife_commands"
require 'rufus-scheduler'
require "routes/v2.0/base_routes"
require "providers/provider_factory"
require "db/mongo/models/deploy_env"
require "commands/status"
require "commands/server"

module Version2_0

    class ExpireHandler
      include ServerCommands

      def initialize server, logger
        @server = server
        @logger = logger
      end

      def call(job)
        @logger.info("Removing node '#{@server.chef_node_name}' form project '#{@server.project}' and env '#{@server.deploy_env}'")
        begin
          delete_server(@server, BaseRoutes.mongo, @logger)
        rescue => e
          logger.error "ExpiredHandler error: " + e.message
        end
      end
    end

  class ServerRoutes < BaseRoutes

    include StatusCommands
    include ServerCommands

    def initialize wrapper
      super wrapper
      puts "Server routes initialized"
    end

    before "/server/:name_or_cmd" do
      if request.get?
        check_headers :accept
      else
        check_headers :accept, :content_type
      end
      check_privileges("server")
    end

    before %r{\A/server/[\w]+/(un)?pause\z} do
      check_headers :accept, :content_type
      check_privileges("server", "w")
    end

    before "/servers/:provider" do
      check_headers :accept
      check_privileges("server", "r")
    end

    after %r{\A/server(/[\w]+)?\z | \A/server/(add|bootstrap)\z | \A/server/[\w]+/(un)?pause\z} do
      statistic
    end

    scheduler = Rufus::Scheduler.new

    # Get devops servers list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     {
    #       "id": "instance id",
    #       "chef_node_name": "chef name"
    #     }
    #   ]
    get "/servers" do
      check_headers :accept
      check_privileges("server", "r")
      json BaseRoutes.mongo.servers.map {|s| s.to_list_hash}
    end

    # Get chef nodes list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     {
    #       "chef_node_name": "chef name"
    #     }
    #   ]
    get "/servers/chef" do
      json KnifeCommands.chef_node_list
    end

    # Get provider servers list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   -ec2
    #   [
    #      {
    #       "state": "running",
    #       "name": "name",
    #       "image": "ami-83e4bcea",
    #       "flavor": "m1.small",
    #       "keypair": "ssh key",
    #       "instance_id": "i-8441bfd4",
    #       "dns_name": "ec2-204-236-199-49.compute-1.amazonaws.com",
    #       "zone": "us-east-1d",
    #       "private_ip": "10.215.217.210",
    #       "public_ip": "204.236.199.49",
    #       "launched_at": "2014-04-25 07:56:33 UTC"
    #     }
    #   ]
    #   -openstack
    #   [
    #     {
    #       "state": "ACTIVE",
    #       "name": "name",
    #       "image": "image id",
    #       "flavor": null,
    #       "keypair": "ssh key",
    #       "instance_id": "instance id",
    #       "private_ip": "172.17.0.1"
    #     }
    #   ]
    get "/servers/:provider" do
      json ::Version2_0::Provider::ProviderFactory.get(params[:provider]).servers
    end

    # Get server info by :name
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     {
    #       "chef_node_name": "chef name"
    #     }
    #   ]
    get "/server/:name" do
      json BaseRoutes.mongo.server_by_chef_node_name(params[:name])
    end

    # Delete devops server
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body
    #   {
    #     "key": "instance" -> if key=instance, then :name - instance id, if key=null, then name - node name
    #   }
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/server/:id" do
      body = create_object_from_json_body(Hash, true)
      key = (body.nil? ? nil : body["key"])
      id = params[:id]
      s = (key == "instance" ? BaseRoutes.mongo.server_by_instance_id(id) : BaseRoutes.mongo.server_by_chef_node_name(id))
      ### Authorization
      BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
      info, r = delete_server(s, BaseRoutes.mongo, logger)
      create_response(info, r)
    end

    # Create devops server
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "project": "project name", -> mandatory parameter
    #       "deploy_env": "env",       -> mandatory parameter
    #       "name": "server_name",     -> if null, name will be generated
    #       "without_bootstrap": null, -> do not install chef on instance if true
    #       "force": null,             -> do not delete server on error
    #       "groups": [],              -> specify special security groups, overrides value from project env
    #       "key": "ssh key"           -> specify ssh key for server, overrides value from project env
    #     }
    #
    # * *Returns* : text stream
    post "/server" do
      check_headers :content_type
      check_privileges("server", "w")
      body = create_object_from_json_body
      user = request.env['REMOTE_USER']
      project_name = check_string(body["project"], "Parameter 'project' must be a not empty string")
      env_name = check_string(body["deploy_env"], "Parameter 'deploy_env' must be a not empty string")
      server_name = check_string(body["name"], "Parameter 'name' should be null or not empty string", true)
      without_bootstrap = body["without_bootstrap"]
      halt_response("Parameter 'without_bootstrap' should be a null or true") unless without_bootstrap.nil? or without_bootstrap == true
      force = body["force"]
      halt_response("Parameter 'force' should be a null or true") unless force.nil? or force == true
      groups = check_array(body["groups"], "Parameter 'groups' should be null or not empty array of string", String, true)
      key_name = check_string(body["key"], "Parameter 'key' should be null or not empty string", true)
      new_key = BaseRoutes.mongo.key(key_name) unless key_name.nil?

      p = BaseRoutes.mongo.check_project_auth(project_name, env_name, user)
      env = p.deploy_env(env_name)

      provider = ::Version2_0::Provider::ProviderFactory.get(env.provider)
      check_chef_node_name(server_name, provider) unless server_name.nil?
      unless groups.nil?
        buf = groups - provider.groups.keys
        halt_response("Invalid security groups '#{buf.join("', '")}' for provider '#{provider.name}'") if buf.empty?
      end

      servers = extract_servers(provider, p, env, body, user, BaseRoutes.mongo)
      stream() do |out|
        status = []
        servers.each do |s|
          begin
            unless provider.create_server(s, out)
              status.push 3
              next
            end
            logger.info "Server with parameters: #{s.to_hash.inspect} is running"
            unless without_bootstrap
              key = new_key || BaseRoutes.mongo.key(s.key)
              bootstrap(s, out, key.path, logger)
              logger.info "Server with id '#{s.id}' is bootstraped"
              if force or check_server(s)
                BaseRoutes.mongo.server_insert s
                scheduler.in(env.expires, ExpireHandler.new(s, logger)) unless env.expires.nil?
                out << "Server #{s.chef_node_name} is created"
                status.push 0
              else
                out << roll_back(s, provider)
                status.push 5
              end
              out << "\n"
            else
              BaseRoutes.mongo.server_insert s
              status.push 0
            end
            out << create_status(status)
          rescue IOError => e
            logger.error e.message
            logger.warn roll_back(s, provider)
            break
          end
        end
      end
    end

    # Pause devops server by name
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Paused
    post "/server/:node_name/pause" do
      s = BaseRoutes.mongo.server_by_chef_node_name params[:node_name]
      ## Authorization
      BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
      provider = ::Version2_0::Provider::ProviderFactory.get(s.provider)
      r = provider.pause_server s.id
      if r.nil?
        create_response("Server with instance ID '#{s.id}' and node name '#{params[:node_name]}' is paused")
      else
        halt_response("Server with instance ID '#{s.id}' and node name '#{params[:node_name]}' can not be paused, It in state '#{r}'", 409)
      end
    end

    # Unpause devops server by name
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Unpaused
    post "/server/:node_name/unpause" do
      s = BaseRoutes.mongo.server_by_chef_node_name params[:node_name]
       ## Authorization
      BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
      provider = ::Version2_0::Provider::ProviderFactory.get(s.provider)
      r = provider.unpause_server s.id
      if r.nil?
        create_response("Server with instance ID '#{s.id}' and node name '#{params[:node_name]}' is unpaused")
      else
        halt_response("Server with instance ID '#{s.id}' and node name '#{params[:node_name]}' can not be unpaused, It in state '#{r}'", 409)
      end
    end

    # Bootstrap devops server
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "instance_id": "instance id", -> mandatory parameter
    #       "name": "server_name", -> if null, name will be generated
    #       "run_list": [], -> specify list of roles and recipes
    #       "bootstrap_template": "template" -> specify ssh key for server, overrides value from project env
    #     }
    #
    # * *Returns* : text stream
    # TODO: check bootstrap template name
    post "/server/bootstrap" do
      body = create_object_from_json_body(Hash, true)
      id = check_string(body["instance_id"], "Parameter 'instance_id' must be a not empty string")
      name = check_string(body["name"], "Parameter 'name' should be a not empty string", true)
      rl = check_array(body["run_list"], "Parameter 'run_list' should be a not empty array of string", String, true)
      unless rl.nil?
        e = DeployEnv.validate_run_list(rl)
        halt_response("Invalid run list elements: '#{e.join("', '")}'") unless e.empty?
      end
      t = check_string(body["bootstrap_template"], "Parameter 'bootstrap_template' should be a not empty string", true)
      s = BaseRoutes.mongo.server_by_instance_id(id)

      p = BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
      d = p.deploy_env s.deploy_env

      s.options = {
        :run_list => rl || d.run_list,
      }
      s.options[:bootstrap_template] = t unless t.nil?
      stream() do |out|
        begin
          s.chef_node_name = name || "static_#{s.key}-#{Time.now.to_i}"
          cert = BaseRoutes.mongo.key s.key
          logger.debug "Bootstrap certificate path: #{cert.path}"
          bootstrap s, out, cert.path, logger
          str = nil
          if check_server(s)
            BaseRoutes.mongo.server_update s
            str = "Server with id '#{s.id}' is bootstraped"
            logger.info str
          else
            str = "Server with id '#{s.id}' is not bootstraped"
            logger.warn str
          end
          out << str
          out << "\n"
        rescue IOError => e
          logger.error e.message
        end
      end
    end

    # Add external server to devops
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "project": "project name", -> mandatory parameter
    #       "deploy_env": "env",       -> mandatory parameter
    #       "key": "ssh key",          -> mandatory parameter
    #       "remote_user": "ssh user", -> mandatory parameter
    #       "private_ip": "ip",         -> mandatory parameter
    #       "public_ip": "ip"
    #     }
    #
    # * *Returns* :
    #   200 - Added
    # TODO: should be refactored
    post "/server/add" do
      body = create_object_from_json_body
      project = check_string(body["project"], "Parameter 'project' must be a not empty string")
      deploy_env = check_string(body["deploy_env"], "Parameter 'deploy_env' must be a not empty string")
      key = check_string(body["key"], "Parameter 'key' must be a not empty string")
      remote_user = check_string(body["remote_user"], "Parameter 'remote_user' must be a not empty string")
      private_ip = check_string(body["private_ip"], "Parameter 'private_ip' must be a not empty string")
      public_ip = check_string(body["public_ip"], "Parameter 'public_ip' should be a not empty string", true)
      p = BaseRoutes.mongo.check_project_auth project, deploy_env, request.env['REMOTE_USER']

      d = p.deploy_env(deploy_env)

      cert = BaseRoutes.mongo.key(key)
      s = Server.new
      s.provider = "static"
      s.project = project
      s.deploy_env = deploy_env
      s.remote_user = remote_user
      s.private_ip = private_ip
      s.public_ip = public_ip
      s.static = true
      s.id = "static_#{cert.id}-#{Time.now.to_i}"
      s.key = cert.id
      BaseRoutes.mongo.server_insert s
      create_response("Server '#{s.id}' has been added")
    end

  private
    def roll_back s, provider
      str = ""
      unless s.id.nil?
        str << "Server '#{s.chef_node_name}' with id '#{s.id}' is not created\n"
        str << delete_from_chef_server(s.chef_node_name).values.join("\n")
        begin
          str << provider.delete_server(s.id) unless s.static
        rescue => e
          str << e.message
        end
        str << "\nRolled back\n"
      end
      return str
    end

    def check_chef_node_name name, provider
      BaseRoutes.mongo.server_by_chef_node_name name
      halt(400, "Server with name '#{name}' already exist")
    rescue RecordNotFound => e
      # server not found - OK
      s = provider.servers.detect {|s| s["name"] == name}
      halt(400, "#{provider.name} node with name '#{name}' already exist") unless s.nil?
      s = KnifeCommands.chef_node_list.detect {|n| n == name}
      halt(400, "Chef node with name '#{name}' already exist") unless s.nil?
      s = KnifeCommands.chef_client_list.detect {|c| c == name}
      halt(400, "Chef client with name '#{name}' already exist") unless s.nil?
    end

  end
end
