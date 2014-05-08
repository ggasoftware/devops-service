require "providers/provider_factory"
require "routes/v2.0/base_routes"
require "fileutils"
require "commands/status"

module Version2_0
  class ScriptRoutes < BaseRoutes

    include StatusCommands

    def initialize wrapper
      super wrapper
      puts "Script routes initialized"
    end

    before "/script/:script_name" do
      check_headers :accept
      check_privileges("script", "w")
      file_name = params[:script_name]
      @file = File.join(DevopsService.config[:scripts_dir], check_filename(file_name, "Parameter 'script_name' must be a not empty string"))
      if request.put?
        halt_response("File '#{file_name}' already exist") if File.exists?(@file)
      elsif request.delete?
        halt_response("File '#{file_name}' does not exist", 404) unless File.exists?(@file)
      end
    end

    after %r{\A/script/((command|run)/)?[\w]+\z} do
      statistic
    end

    # Get scripts names
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     "script_1"
    #   ]
    get "/scripts" do
      check_headers :accept
      check_privileges("script", "r")
      res = []
      Dir.foreach(DevopsService.config[:scripts_dir]) {|f| res.push(f) unless f.start_with?(".")}
      json res
    end

    # Run command on node :node_name
    #
    # * *Request*
    #   - method : POST
    #   - body :
    #     command to run
    #
    # * *Returns* : text stream
    post "/script/command/:node_name" do
      check_privileges("script", "w")
      user = request.env['REMOTE_USER']
      s = BaseRoutes.mongo.server_by_chef_node_name params[:node_name]
      BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, user
      cert = BaseRoutes.mongo.key s.key
      cmd = request.body.read
      addr = "#{s.remote_user}@#{s.public_ip || s.private_ip}"
      ssh_cmd = "ssh -i %s #{addr} '#{cmd}'"
      stream() do |out|
        begin
          out << ssh_cmd % File.basename(cert.path)
          out << "\n"
          IO.popen((ssh_cmd % cert.path) + " 2>&1") do |so|
            while line = so.gets do
              out << line
            end
          end
          out << "\nDone"
        rescue IOError => e
          logger.error e.message
        end
      end
    end

    # Run script :script_name on nodes
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "nodes": [], -> array of nodes names
    #       "params": [] -> array of script arguments
    #     }
    #
    # * *Returns* : text stream
    post "/script/run/:script_name" do
      check_headers :content_type
      check_privileges("script", "w")
      file_name = params[:script_name]
      @file = File.join(DevopsService.config[:scripts_dir], check_filename(file_name, "Parameter 'script_name' must be a not empty string", false))
      halt(404, "File '#{file_name}' does not exist") unless File.exists?(@file)
      body = create_object_from_json_body
      nodes = check_array(body["nodes"], "Parameter 'nodes' must be a not empty array of strings")
      p = check_array(body["params"], "Parameter 'params' should be a not empty array of strings", String, true)
      servers = BaseRoutes.mongo.servers_by_names(nodes)
      return [404, "No servers found for names '#{nodes.join("', '")}'"] if servers.empty?
      user = request.env['REMOTE_USER']
      servers.each do |s|
        BaseRoutes.mongo.check_project_auth s.project, s.deploy_env, user
      end
      stream() do |out|
        begin
          status = []
          servers.each do |s|
            cert = begin
              BaseRoutes.mongo.key s.key
            rescue
              out << "No key found for '#{s.chef_node_name}'"
              status.push 2
              next
            end
            ssh_cmd = "ssh -i #{cert.path} #{s.remote_user}@#{s.public_ip || s.private_ip} 'bash -s' < %s"
            out << "\nRun script on '#{s.chef_node_name}'\n"
            unless p.nil?
              ssh_cmd += " " + p.join(" ")
            end
            out << (ssh_cmd % [params[:script_name]])
            out << "\n"

            begin
              IO.popen( (ssh_cmd % [@file]) + " 2>&1") do |so|
                while line = so.gets do
                  out << line
                end
                so.close
                status.push $?.to_i
              end
            rescue IOError => e
              logger.error e.message
              out << e.message
              status.push 3
            end
          end
          out << create_status(status)
        rescue IOError => e
          logger.error e.message
        end
      end
    end

    # Create script :script_name
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #   - body : script content
    #
    # * *Returns* :
    #   201 - Created
    put "/script/:script_name" do
      File.open(@file, "w") {|f| f.write(request.body.read)}
      create_response("File '#{params[:script_name]}' created", nil, 201)
    end

    # Delete script :script_name
    #
    # * *Request*
    #   - method : Delete
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/script/:script_name" do
      FileUtils.rm(@file)
      create_response("File '#{params[:script_name]}' deleted")
    end
  end
end
