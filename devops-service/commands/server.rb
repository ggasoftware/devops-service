require "commands/knife_commands"
require "db/exceptions/record_not_found"

module ServerCommands

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
      s.chef_node_name = info[:name] || "#{provider.ssh_key}-#{project_name}-#{env_name}-#{Time.now.to_i}"
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
    i = 0
    begin
      sleep(1)
      `ssh -i #{cert_path} -q #{s.remote_user}@#{ip} exit`
      i += 1
      if i == 300
        res = `ssh -i #{cert_path} #{s.remote_user}@#{ip} "exit" 2>&1`
        out << "\nCan not connect to #{s.remote_user}@#{ip}"
        out << "\n" + res
        logger.error "Can not connect with command 'ssh -i #{cert_path} #{s.remote_user}@#{ip}':\n#{res}"
        return false
      end
      raise unless $?.success?
    rescue
      retry
    end

    bootstrap_cmd = "knife bootstrap #{bootstrap_options.join(" ")} #{ip}"
    out << "\nExecuting '#{bootstrap_cmd}' \n\n"
    status = nil
    IO.popen(bootstrap_cmd + " 2>&1") do |bo|
      while line = bo.gets do
        out << line
      end
      bo.close
      status = $?.to_i
    end
    return status
  end

  def unbootstrap s, cert_path
    i = 0
    begin
      `ssh -i #{cert_path} -q #{s.remote_user}@#{s.private_ip} rm -Rf /etc/chef`
      raise unless $?.success?
    rescue => e
      logger.error "Unbootstrap eeror: " + e.message
      i += 1
      sleep(1)
      retry unless i == 5
    end
  end

  def delete_server s, mongo, logger
    if s.chef_node_name.nil?
      mongo.server_delete s.id
      msg = "Added server '#{s.id}' is removed"
      logger.info msg
      return msg, nil
    end
    r = delete_from_chef_server(s.chef_node_name)
    info = if s.static
      cert = mongo.key(s.key).path
      unbootstrap(s, cert)
      mongo.server_delete s.id
      msg = "Static server '#{s.id}' with name '#{s.chef_node_name}' for project '#{s.project}-#{s.deploy_env}' is removed"
      logger.info msg
      msg
    else
      provider = ::Version2_0::Provider::ProviderFactory.get(s.provider)
      begin
        r[:server] = provider.delete_server s.id
      rescue Fog::Compute::OpenStack::NotFound, Fog::Compute::AWS::NotFound
        r[:server] = "Server with id '#{s.id}' not found in '#{provider.name}' servers"
        logger.warn r[:server]
      end
      mongo.server_delete s.id
      msg = "Server '#{s.id}' with name '#{s.chef_node_name}' for project '#{s.project}-#{s.deploy_env}' is removed"
      logger.info msg
      msg
    end
    r.each{|key, log| logger.info("#{key} - #{log}")}
    return info, r
  end

end
