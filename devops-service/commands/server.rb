require "commands/knife_commands"
require "commands/deploy"
require "db/exceptions/record_not_found"

module ServerCommands

  include DeployCommands

  def create_server_proc
    lambda do |out, s, provider, mongo|
      begin
        out << "Create server...\n"
        out.flush if out.respond_to?(:flush)
        unless provider.create_server(s, out)
          return 3
        end
        mongo.server_insert s
        out.flush if out.respond_to?(:flush)
        logger.info "Server with parameters: #{s.to_hash.inspect} is running"
        key = mongo.key(s.key)
        s.chef_node_name = provider.create_default_chef_node_name(s) if s.chef_node_name.nil?
        return two_phase_bootstrap(s, out, provider, mongo, key.path, logger)
      rescue IOError => e
        logger.error e.message
        logger.warn roll_back(s, provider)
        mongo.server_delete s.id
        return 5
      end
    end
  end

  def create_server_proc
    lambda do |out, s, provider, mongo|
      begin
        out << "Create server...\n"
        out.flush if out.respond_to?(:flush)
        unless provider.create_server(s, out)
          return 3
        end
        mongo.server_insert s
        out.flush if out.respond_to?(:flush)
        logger.info "Server with parameters: #{s.to_hash.inspect} is running"
        key = mongo.key(s.key)
        s.chef_node_name = provider.create_default_chef_node_name(s) if s.chef_node_name.nil?
        out << "\n\nBootstrap..."
        out.flush if out.respond_to?(:flush)
        run_list = s.options[:run_list]
        s.options[:run_list] = provider.run_list
        out << "\nBootstrap with provider run list: #{s.options[:run_list].inspect}"
        status = bootstrap(s, out, key.path, logger)
        out.flush if out.respond_to?(:flush)
        if status == 0
          mongo.server_set_chef_node_name s
          logger.info "Server with id '#{s.id}' is bootstraped"
          if check_server(s)
            out << "Server #{s.chef_node_name} is created"
          else
            out << roll_back(s, provider)
            mongo.server_delete s.id
            return 5
          end
          out << "\n"
          out.flush if out.respond_to?(:flush)

          out << "\nAdd project run list: #{run_list.inspect}"
          s.options[:run_list] += run_list
          KnifeCommands.set_run_list(s.chef_node_name, s.options[:run_list])
          status = deploy_server(out, s, key.path)
          if status != 0
            msg = "Failed on chef-client with project run list, server with id '#{s.id}'"
            logger.error msg
            out << "\n" + msg + "\n"
            mongo.server_delete s.id
          end
          return status
        else
          msg = "Failed while bootstraping server with id '#{s.id}'"
          logger.error msg
          out << "\n" + msg + "\n"
          out << roll_back(s, provider)
          mongo.server_delete s.id
          status
        end
      rescue IOError => e
        logger.error e.message
        logger.warn roll_back(s, provider)
        mongo.server_delete s.id
        return 5
      end
    end
  end

  def two_phase_bootstrap s, out, provider, mongo, cert_path, logger
      out << "\n\nBootstrap..."
      out.flush if out.respond_to?(:flush)
      run_list = s.options[:run_list]
      s.options[:run_list] = provider.run_list
      out << "\nBootstrap with provider run list: #{s.options[:run_list].inspect}"
      status = bootstrap(s, out, cert_path, logger)
      out.flush if out.respond_to?(:flush)
      if status == 0
        mongo.server_set_chef_node_name s
        logger.info "Server with id '#{s.id}' is bootstraped"
        if check_server(s)
          out << "Server #{s.chef_node_name} is created"
        else
          out << roll_back(s, provider)
          mongo.server_delete s.id
          return 5
        end
        out << "\n"
        out.flush if out.respond_to?(:flush)

        out << "\nAdd project run list: #{run_list.inspect}"
        s.options[:run_list] += run_list
        KnifeCommands.set_run_list(s.chef_node_name, s.options[:run_list])
        status = deploy_server(out, s, cert_path)
        if status != 0
          msg = "Failed on chef-client with project run list, server with id '#{s.id}'"
          logger.error msg
          out << "\n" + msg + "\n"
        end
      else
        msg = "Failed while bootstraping server with id '#{s.id}'"
        logger.error msg
        out << "\n" + msg + "\n"
        out << roll_back(s, provider)
        mongo.server_delete s.id
      end
      return status
  end

  def extract_servers provider, project, env, params, user, mongo
    flavors = provider.flavors
    projects = {}
    env_name = env.identifier
    project_name = project.id
    servers_info = []
    if project.multi?
      #TODO: fix multi project
      images = {}
      env.servers.each do |name, server|
        images[server["image"]] = mongo.image(server["image"]) unless images.has_key?(server["image"])
        flavor = flavors.detect {|f| f["name"] == server["flavor"]}
        raise RecordNotFound.new("Flavor with name '#{server["flavor"]}' not found") if flavor.nil?
        run_list = []
        project_ids = server["subprojects"].map{|sp| sp["project_id"]}
        db_subprojects = mongo.projects project_ids
        ids = project_ids - db_subprojects.map{|sp| sp.id}
        unless ids.empty?
          return [400, "Subproject(s) '#{ids.join("', '")}' is/are not exists"]
        end
        server["subprojects"].each do |sp|
          p = db_subprojects.detect{|db_sp| db_sp.id == sp["project_id"]}
          run_list += p.deploy_env(sp["project_env"]).run_list
        end
        o = {
          :image => images[server["image"]],
          :name => "#{name}_#{Time.now.to_i}",
          :flavor => flavor["id"],
          :groups => server["groups"],
          :run_list => run_list
        }
        servers_info.push(o)
      end
    else
      i = mongo.image env.image
      flavor = flavors.detect {|f| f["id"] == env.flavor}
      raise RecordNotFound.new("Flavor with id '#{env.flavor}' not found") if flavor.nil?
      o = {
        :image => i,
        :name => params["name"],
        :flavor => flavor["id"],
        :groups => params["groups"] || env.groups,
        :run_list => env.run_list,
        :subnets => env.subnets,
        :key => params["key"]
      }
      servers_info.push(o)
    end

    servers = []
    servers_info.each do |info|
      image = info[:image]
      s = Server.new
      s.provider = provider.name
      s.project = project_name
      s.deploy_env = env_name
      s.remote_user = image.remote_user
      s.chef_node_name = info[:name] || provider.create_default_chef_node_name(s)
      s.key = info[:key] || provider.ssh_key
      s.options = {
        :image => image.id,
        :flavor => info[:flavor],
        :name => info[:name],
        :groups => info[:groups],
        :run_list => info[:run_list],
        :bootstrap_template => image.bootstrap_template,
        :subnets => info[:subnets]
      }
      s.created_by = user
      servers.push s
    end
    return servers
  end

  def delete_from_chef_server node_name
    {
      :chef_node => KnifeCommands.chef_node_delete(node_name),
      :chef_client => KnifeCommands.chef_client_delete(node_name)
    }
  end

  def check_server s
    KnifeCommands.chef_node_list.include?(s.chef_node_name) and KnifeCommands.chef_client_list.include?(s.chef_node_name)
  end

  def bootstrap s, out, cert_path, logger
    if s.private_ip.nil?
      out << "Error: Private IP is null"
      return false
    end
    ja = {
      :provider => s.provider,
      :devops_host => `hostname`.strip
    }
    bootstrap_options = [
      "-x #{s.remote_user}",
      "-i #{cert_path}",
      "--json-attributes '#{ja.to_json}'"
    ]
    bootstrap_options.push "--sudo" unless s.remote_user == "root"
    bootstrap_options.push "-N #{s.chef_node_name}" if s.chef_node_name
    bootstrap_options.push "-d #{s.options[:bootstrap_template]}" if s.options[:bootstrap_template]
    bootstrap_options.push "-r #{s.options[:run_list].join(",")}" unless s.options[:run_list].empty?
    ip = s.private_ip
    unless s.public_ip.nil? || s.public_ip.strip.empty?
      ip = s.public_ip
      out << "\nPublic IP is present\n"
    end
    out << "\nWaiting for SSH..."
    out.flush if out.respond_to?(:flush)
    i = 0
    cmd = "ssh -i #{cert_path} -q #{s.remote_user}@#{ip} 'exit' 2>&1"
    begin
      sleep(5)
      res = `#{cmd}`
      i += 1
      if i == 120
        out << "\nCan not connect to #{s.remote_user}@#{ip}"
        out << "\n" + res
        logger.error "Can not connect with command 'ssh -i #{cert_path} #{s.remote_user}@#{ip}':\n#{res}"
        return false
      end
      raise ArgumentError.new("Can not connect with command '#{cmd}' ") unless $?.success?
    rescue ArgumentError => e
      retry
    end

    return KnifeCommands.knife_bootstrap(out, ip, bootstrap_options)
  end

  def self.unbootstrap s, cert_path
    i = 0
    begin
      r = `ssh -i #{cert_path} -q #{s.remote_user}@#{s.private_ip} rm -Rf /etc/chef`
      raise(r) unless $?.success?
    rescue => e
      logger.error "Unbootstrap error: " + e.message
      i += 1
      sleep(1)
      retry unless i == 5
      return e.message
    end
    nil
  end

  def delete_server s, mongo, logger
    if s.static?
      if !s.chef_node_name.nil?
        cert = BaseRoutes.mongo.key s.key
        ServerCommands.unbootstrap(s, cert.path)
      end
      mongo.server_delete s.id
      msg = "Static server '#{s.id}' is removed"
      logger.info msg
      return msg, nil
    end
    r = delete_from_chef_server(s.chef_node_name)
    provider = ::Provider::ProviderFactory.get(s.provider)
    begin
      r[:server] = provider.delete_server s
    rescue Fog::Compute::OpenStack::NotFound, Fog::Compute::AWS::NotFound
      r[:server] = "Server with id '#{s.id}' not found in '#{provider.name}' servers"
      logger.warn r[:server]
    end
    mongo.server_delete s.id
    info = "Server '#{s.id}' with name '#{s.chef_node_name}' for project '#{s.project}-#{s.deploy_env}' is removed"
    logger.info info
    r.each{|key, log| logger.info("#{key} - #{log}")}
    return info, r
  end

  def roll_back s, provider
    str = ""
    unless s.id.nil?
      str << "Server '#{s.chef_node_name}' with id '#{s.id}' is not created\n"
      str << delete_from_chef_server(s.chef_node_name).values.join("\n")
      begin
        str << provider.delete_server(s)
      rescue => e
        str << e.message
      end
      str << "\nRolled back\n"
    end
    return str
  end

end
