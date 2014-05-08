require "json"
require "db/mongo/models/project"
require "db/mongo/models/deploy_env"
require "db/exceptions/invalid_record"
require "commands/deploy"
require "commands/status"
require "commands/server"

module Version2_0
  class ProjectRoutes < BaseRoutes

    include DeployCommands
    include StatusCommands
    include ServerCommands

    def initialize wrapper
      super wrapper
      puts "Project routes initialized"
    end

    before "/project/:id" do
      if request.get?
        check_headers :accept
      else
        check_headers :accept, :content_type
      end
      check_privileges("project")
    end

    before "/project/:id/user" do
      check_headers :accept, :content_type
      check_privileges("project", "w")
      body = create_object_from_json_body
      @users = check_array(body["users"], "Parameter 'users' must be a not empty array of strings")
      @deploy_env = check_string(body["deploy_env"], "Parameter 'deploy_env' must be a not empty string", true)
      @project = BaseRoutes.mongo.project(params[:id])
    end

    after %r{\A/project(/[\w]+(/(user|deploy))?)?\z} do
      statistic
    end

    after "/project/:id/:env/run_list" do
      statistic
    end

    # Get projects list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     "project_1"
    #   ]
    # TODO: list with environments
    get "/projects" do
      check_headers :accept
      check_privileges("project", "r")
      json BaseRoutes.mongo.projects.map {|p| p.id}
    end

    # Get project by id
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   {
    #     "deploy_envs": [
    #       {
    #         "flavor": "flavor",
    #         "identifier": "prod",
    #         "image": "image id",
    #         "run_list": [
    #           "role[project_1-prod]"
    #         ],
    #         "subnets": [
    #           "private"
    #         ],
    #         "expires": null,
    #         "provider": "openstack",
    #         "groups": [
    #           "default"
    #         ],
    #         "users": [
    #           "user"
    #         ]
    #       }
    #     ],
    #     "name": "project_1"
    #   }
    get "/project/:project" do
      json BaseRoutes.mongo.project(params[:project])
    end

    # Get project servers
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #   - parameters :
    #     - deploy_env=:env -> show servers with environment :env
    #
    # * *Returns* :
    #   [
    #     {
    #       "provider": "openstack",
    #       "chef_node_name": "project_1_server",
    #       "remote_user": "root",
    #       "project": "project_1",
    #       "deploy_env": "prod",
    #       "private_ip": "10.8.8.8",
    #       "public_ip": null,
    #       "created_at": "2014-04-23 13:35:18 UTC",
    #       "created_by": "user",
    #       "static": false,
    #       "key": "ssh key",
    #       "id": "nstance id"
    #     }
    #   ]
    get "/project/:project/servers" do
      check_headers :accept
      check_privileges("project", "r")
      BaseRoutes.mongo.project(params[:project])
      json BaseRoutes.mongo.servers(params[:project], params[:deploy_env]).map{|s| s.to_hash}
    end

    # Create project and chef roles
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "deploy_envs": [
    #         {
    #           "identifier": "prod",
    #           "provider": "openstack",
    #           "flavor": "m1.small",
    #           "image": "image id",
    #           "subnets": [
    #             "private"
    #           ],
    #           "groups": [
    #             "default"
    #           ],
    #           "users": [
    #             "user"
    #           ],
    #           "run_list": [
    #
    #           ],
    #           "expires": null
    #         }
    #       ],
    #       "name": "project_1"
    #     }
    #
    # * *Returns* :
    #   201 - Created
    # TODO: multi project
    post "/project" do
      check_headers :accept, :content_type
      check_privileges("project", "w")
      body = create_object_from_json_body
      check_string(body["name"], "Parameter 'name' must be a not empty string")
      check_array(body["deploy_envs"], "Parameter 'deploy_envs' must be a not empty array of objects", Hash)
      p = Project.new(body)
      halt_response("Project '#{p.id}' already exist") if BaseRoutes.mongo.is_project_exists?(p)
      p.add_authorized_user [request.env['REMOTE_USER']]
      BaseRoutes.mongo.project_insert p
      roles_res = ""
      if p.multi?
        logger.info "Project '#{p.id}' with type 'multi' created"
      else
        logger.info "Project '#{p.id}' created"
        roles = create_roles p.id, p.deploy_envs, logger
        roles_res = ". " + create_roles_response(roles)
      end
      res = "Created" + roles_res
      create_response(res, nil, 201)
    end

    # Update project and create chef roles
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "deploy_envs": [
    #         {
    #           "identifier": "dev",
    #           "provider": "openstack",
    #           "flavor": "m1.small",
    #           "image": "image id",
    #           "subnets": [
    #             "private"
    #           ],
    #           "groups": [
    #             "default"
    #           ],
    #           "users": [
    #             "user"
    #           ],
    #           "run_list": [
    #
    #           ],
    #           "expires": null
    #         }
    #       ],
    #       "name": "project_1"
    #     }
    #
    # * *Returns* :
    #   200 - Updated
    # TODO: multi project
    put "/project/:id" do
      project = Project.new(create_object_from_json_body)
      project.id = params[:id]
      old_project = BaseRoutes.mongo.project params[:id]
      BaseRoutes.mongo.project_update project
      roles = create_new_roles(old_project, project, logger)
      info = "Project '#{project.id}' has been updated." + create_roles_response(roles)
      create_response(info)
    end

    # Add users to project environment
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "users": [
    #         "user1"
    #       ],
    #       "deploy_env": "env" -> if null, users will be added to all environments
    #     }
    #
    # * *Returns* :
    #   200 - Updated
    # TODO: multi project
    put "/project/:id/user" do
      users = BaseRoutes.mongo.users(@users).map{|u| u.id}
      buf = @users - users
      @project.add_authorized_user users, @deploy_env
      BaseRoutes.mongo.project_update(@project)
      info = "Users '#{users.join("', '")}' have been added to '#{params[:id]}' project's authorized users"
      info << ", invalid users: '#{buf.join("', '")}'" unless buf.empty?
      create_response(info)
    end

    # Delete users from project environment
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "users": [
    #         "user1"
    #       ],
    #       "deploy_env": "env" -> if null, users will be deleted from all environments
    #     }
    #
    # * *Returns* :
    #   200 - Updated
    # TODO: multi project
    delete "/project/:id/user" do
      @project.remove_authorized_user @users, @deploy_env
      BaseRoutes.mongo.project_update @project
      info = "Users '#{@users.join("', '")}' have been removed from '#{params[:id]}' project's authorized users"
      create_response(info)
    end

    # Set run_list to project environment
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     [
    #       "role[role_1]",
    #       "recipe[recipe_1]"
    #     ]
    #
    # * *Returns* :
    #   200 - Updated
    # TODO: multi project
    put "/project/:id/:env/run_list" do
      check_headers :accept, :content_type
      check_privileges("project", "w")
      list = create_object_from_json_body(Array)
      check_array(list, "Body must contains not empty array of strings")
      project = BaseRoutes.mongo.project(params[:id])
      env = project.deploy_env params[:env]
      env.run_list = list
      BaseRoutes.mongo.project_update project
      create_response("Updated environment '#{env.identifier}' with run_list '#{env.run_list.inspect}' in project '#{project.id}'")
    end

    # Delete project
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "deploy_env": "env" -> if not null, will be deleted environment only
    #     }
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/project/:id" do
      servers = BaseRoutes.mongo.servers params[:id]
      raise DependencyError.new "Deleting #{params[:id]} is forbidden: Project has servers" if !servers.empty?
      body = create_object_from_json_body(Hash, true)
      deploy_env = unless body.nil?
        check_string(body["deploy_env"], "Parameter 'deploy_env' should be a not empty string", true)
      end
      info = if deploy_env.nil?
        BaseRoutes.mongo.project_delete(params[:id])
        "Project '#{params[:id]}' is deleted"
      else
        project = BaseRoutes.mongo.project(params[:id])
        project.remove_env params[:deploy_env]
        BaseRoutes.mongo.project_update project
        "Project '#{params[:id]}'. Deploy environment '#{params[:deploy_env]}' has been deleted"
      end
      create_response(info)
    end

    # Run chef-client on project servers
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "servers": [
    #         "server_1"
    #       ], -> deploy servers from list, all servers if null
    #       "deploy_env": "env" -> deploy servers with environment 'env' or all project servers if null
    #     }
    #
    # * *Returns* : text stream
    post "/project/:id/deploy" do
      check_headers :content_type
      check_privileges("project", "w")
      obj = create_object_from_json_body
      check_string(obj["deploy_env"], "Parameter 'deploy_env' should be a not empty string", true)
      check_array(obj["servers"], "Parameter 'servers' should be a not empty array of strings", String, true)
      project = BaseRoutes.mongo.project(params[:id])
      servers = BaseRoutes.mongo.servers(params[:id], obj["deploy_env"])
      unless obj["servers"].nil?
        logger.debug "Servers in params: #{obj["servers"].inspect}\nServers: #{servers.map{|s| s.chef_node_name}.inspect}"
        servers.select!{|ps| obj["servers"].include?(ps.chef_node_name)}
      end
      keys = {}
      stream() do |out|
        begin
          out << (servers.empty? ? "No servers to deploy\n" : "Deploy servers: '#{servers.map{|s| s.chef_node_name}.join("', '")}'\n")
          status = []
          servers.each do |s|

            begin
              BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, request.env['REMOTE_USER']
            rescue InvalidPrivileges, RecordNotFound  => e
              out << e.message + "\n"
              status.push 2
              next
            end
            unless keys.key? s.key
              k = BaseRoutes.mongo.key s.key
              keys[s.key] = k.path
            end
            status.push(deploy_server out, s, keys[s.key])
          end
          out << create_status(status)
        rescue IOError => e
          logger.error e.message
        end
      end
    end

    # Test project environment
    #
    # Run tests:
    #   - run server
    #   - bootstrap server
    #   - delete server
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #
    # * *Returns* :
    #   200 -
    #   {
    #     "servers": [
    #       {
    #         "id": "132958f0-61c5-4665-8cc3-66e1bacd285b",
    #         "create": {
    #           "status": true,
    #           "time": "155s"
    #         },
    #         "chef_node_name": "chef name",
    #         "bootstrap": {
    #           "status": true,
    #           "log": "\nWaiting for SSH...\n"
    #           "return_code": 0
    #         },
    #         "delete": {
    #           "status": true,
    #           "time": "2s"
    #           "log": {
    #             "chef_node": "Deleted node[chef name]",
    #             "chef_client": "Deleted client[chef name]",
    #             "server": "Server with id '132958f0-61c5-4665-8cc3-66e1bacd285b' terminated"
    #           }
    #         },
    #       }
    #     ],
    #     "project": {
    #       "deploy_envs": [
    #         {
    #           "flavor": "flavor",
    #           "identifier": "prod",
    #           "image": "image id",
    #           "run_list": [
    #             "role[prod]"
    #           ],
    #           "subnets": [
    #             "private"
    #           ],
    #           "expires": null,
    #           "provider": "openstack",
    #           "groups": [
    #             "default"
    #           ],
    #           "users": [
    #             "root"
    #           ]
    #         }
    #       ],
    #       "name": "prject_1"
    #     },
    #     "message": "Test project 'project_1' and environment 'prod'"
    #   }
    post "/project/test/:id/:env" do
      check_headers :accept, :content_type
      check_privileges("project", "r")
      project = BaseRoutes.mongo.project(params[:id])
      env = project.deploy_env params[:env]
      user = request.env['REMOTE_USER']
      provider = ::Version2_0::Provider::ProviderFactory.get(env.provider)
      header = "Test project '#{project.id}' and environment '#{env.identifier}'"
      logger.info header
      servers = extract_servers(provider, project, env, {}, user, BaseRoutes.mongo)
      result = {:servers => []}
      project.deploy_envs = [ env ]
      result[:project] = project.to_hash
      servers.each do |s|
        sr = {}
        t1 = Time.now
        out = ""
        if provider.create_server(s, out)
          t2 = Time.now
          sr[:id] = s.id
          sr[:create] = {:status => true}
          sr[:create][:time] = time_diff_s(t1, t2)
          logger.info "Server with parameters: #{s.to_hash.inspect} is running"
          key = BaseRoutes.mongo.key(s.key)
          b_out = ""
          r = bootstrap(s, b_out, key.path, logger)
          t1 = Time.now
          sr[:chef_node_name] = s.chef_node_name
          if r == 0
            sr[:bootstrap] = {:status => true}
            sr[:bootstrap][:time] = time_diff_s(t2, t1)
            logger.info "Server with id '#{s.id}' is bootstraped"
            if check_server(s)
              BaseRoutes.mongo.server_insert s
            end
          else
            sr[:bootstrap] = {:status => false}
            sr[:bootstrap][:log] = b_out
            sr[:bootstrap][:return_code] = r
          end

          t1 = Time.now
          r = delete_from_chef_server(s.chef_node_name)
          begin
            r[:server] = provider.delete_server s.id
          rescue Fog::Compute::OpenStack::NotFound, Fog::Compute::AWS::Error
            r[:server] = "Server with id '#{s.id}' not found in '#{provider.name}' servers"
            logger.warn r[:server]
          end
          BaseRoutes.mongo.server_delete s.id
          t2 = Time.now
          sr[:delete] = {:status => true}
          sr[:delete][:time] = time_diff_s(t1, t2)
          sr[:delete][:log] = r
        else
          sr[:create] = {:status => false}
          sr[:create][:log] = out
        end
        result[:servers].push sr
      end
      create_response(header, result)
    end

  private
    def create_roles project_id, envs, logger
      all_roles = KnifeCommands.roles
      return "Can't get roles list" if all_roles.nil?
      roles = {:new => [], :error => [], :exist => []}
      envs.each do |e|
        role_name = project_id + (DevopsService.config[:role_separator] || "_") + e.identifier
        begin
          if all_roles.include? role_name
            roles[:exist].push role_name
          else
            KnifeCommands.create_role project_id, e.identifier
            roles[:new].push role_name
            logger.info "Role '#{role_name}' created"
          end
        rescue => er
          roles[:error].push role_name
          logger.error "Role '#{role_name}' can not be created: #{er.message}"
        end
      end
      roles
    end

    def create_new_roles old_project, new_project, logger
      old_project.deploy_envs.each do |e|
        new_project.remove_env(e.identifier)
      end
      create_roles new_project.id, new_project.deploy_envs, logger
    end

    def create_roles_response roles
      info = ""
      info += " Project roles '#{roles[:new].join("', '")}' have been automaticaly created" unless roles[:new].empty?
      info += " Project roles '#{roles[:exist].join("', '")}' weren't created because they exist" unless roles[:exist].empty?
      info += " Project roles '#{roles[:error].join("', '")}' weren't created because of internal error" unless roles[:error].empty?
      info
    end
  end
end

