require "json"
require "db/exceptions/invalid_record"
require "db/mongo/models/user"

module Version2_0
  class UserRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "User routes initialized"
    end

    after %r{\A/user(/[\w]+(/password)?)?\z} do
      statistic
    end

    # Get users list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     {
    #       "email": "test@test.test",
    #       "privileges": {
    #         "flavor": "r",
    #         "group": "r",
    #         "image": "r",
    #         "project": "r",
    #         "server": "r",
    #         "key": "r",
    #         "user": "",
    #         "filter": "r",
    #         "network": "r",
    #         "provider": "r",
    #         "script": "r",
    #         "templates": "r"
    #       },
    #       "id": "test"
    #     }
    #   ]
    get "/users" do
      check_headers :accept
      check_privileges("user", "r")
      users = BaseRoutes.mongo.users.map {|i| i.to_hash}
      users.each {|u| u.delete("password")}
      json users
    end

    # Create user
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #   {
    #     "username": "user name",
    #     "password": "user password"
    #   }
    #
    # * *Returns* :
    #   201 - Created
    post "/user" do
      check_headers :accept, :content_type
      check_privileges("user", "w")
      user = create_object_from_json_body
      ["username", "password"].each do |p|
        check_string(user[p], "Parameter '#{p}' must be a not empty string")
      end
      BaseRoutes.mongo.user_insert User.new(user)
      create_response("Created", nil, 201)
    end

    # Delete user
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/user/:user" do
      check_headers :accept
      check_privileges("user", "w")
      projects = BaseRoutes.mongo.projects_by_user params[:user]
      if !projects.empty?
        str = ""
        projects.each do |p|
          p.deploy_envs.each do |e|
            str+="#{p.id}.#{e.identifier} " if e.users.include? params[:user]
          end
        end
        logger.info projects
        raise DependencyError.new "Deleting is forbidden: User is included in #{str}"
        #return [400, "Deleting is forbidden: User is included in #{str}"]
      end

      r = BaseRoutes.mongo.user_delete params[:user]
      create_response("User '#{params[:user]}' removed")
    end

    # Change user privileges
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #   {
    #     "cmd": "command or all", -> if empty, set default privileges
    #     "privileges": "priv" -> 'r', 'rw' or ''
    #   }
    #
    # * *Returns* :
    #   200 - Updated
    put "/user/:user" do
      check_headers :accept, :content_type
      check_privileges("user", "w")
      data = create_object_from_json_body
      user = BaseRoutes.mongo.user params[:user]
      cmd = check_string(data["cmd"], "Parameter 'cmd' should be a not empty string", true) || ""
      privileges = check_string(data["privileges"], "Parameter 'privileges' should be a not empty string", true) || ""
      user.grant(cmd, privileges)
      BaseRoutes.mongo.user_update user
      create_response("Updated")
    end

    # Change user email/password
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #   {
    #     "email/password": "new user email/password",
    #   }
    #
    # * *Returns* :
    #   200 - Updated
    put %r{\A/user/[\w]+/(email|password)\z} do
      check_headers :accept, :content_type
      action = File.basename(request.path)
      u = File.basename(File.dirname(request.path))
      raise InvalidPrivileges.new("Access denied for '#{request.env['REMOTE_USER']}'") if u == User::ROOT_USER_NAME and request.env['REMOTE_USER'] != User::ROOT_USER_NAME

      check_privileges("user", "w") unless request.env['REMOTE_USER'] == u

      body = create_object_from_json_body
      p = check_string(body[action], "Parameter '#{action}' must be a not empty string")
      user = BaseRoutes.mongo.user u
      user.send("#{action}=", p)
      BaseRoutes.mongo.user_update user
      create_response("Updated")
    end

  end
end
