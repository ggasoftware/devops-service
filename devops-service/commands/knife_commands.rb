require "json"

class KnifeCommands

  def self.chef_node_list
    knife("node list")[0].split.map{|c| c.strip}
  end

  def self.chef_client_list
    knife("client list")[0].split.map{|c| c.strip}
  end

  def self.chef_node_delete name
    o = knife("node delete #{name} -y")[0]
    (o.nil? ? o : o.strip)
  end

  def self.chef_client_delete name
    o = knife("client delete #{name} -y")[0]
    (o.nil? ? o : o.strip)
  end

  def self.tags_list name
    knife("tag list #{name}")[0].split.map{|c| c.strip}
  end

  def self.tags_create name, tagsStr
    knife("tag create #{name} #{tagsStr}")
  end

  def self.tags_delete name, tagsStr
    knife("tag delete #{name} #{tagsStr}")
  end

  def self.create_role role_name, project, env
    file = "/tmp/new_role.json"
    File.open(file, "w") do |f|
      f.puts <<-EOH
{
  "name" : "#{role_name}",
  "description": "",
  "json_class": "Chef::Role",
  "default_attributes": {
    "project": "#{project}",
    "env": "#{env}"
  },
  "override_attributes": {},
  "chef_type": "role",
  "run_list": [],
  "env_run_lists": {}
}
EOH
    end
    out = `knife role from file #{file}`
    raise "Cannot create role '#{role_name}': #{out}" unless $?.success?
    true
  end

  def self.roles
    o, s = knife("role list --format json")
    return (s ? JSON.parse(o) : nil)
  end

  def self.role_name project_name, deploy_env
    project_name + (DevopsService.config[:role_separator] || "_") + deploy_env
  end

  def self.knife cmd
    o = `knife #{cmd} 2>&1`
    return o, $?.success?
  end

  def self.ssh_options cmd, host, user, cert
    ["-m", "-x", user, "-i", cert, "--no-host-key-verify", host, "'#{(user == "root" ? cmd : "sudo #{cmd}")}'"]
  end

  def self.ssh_stream out, cmd, host, user, cert
    knife_cmd = "knife ssh -c #{get_config()} #{ssh_options(cmd, host, user, cert).join(" ")}"
    out << "\nExecuting '#{knife_cmd}' \n\n"
    out.flush if out.respond_to?(:flush)
    status = 2
    lline = nil
    IO.popen(knife_cmd + " 2>&1") do |o|
      while line = o.gets do
        out << line
        lline = line
        out.flush if out.respond_to?(:flush)
      end
      o.close
    end
    return lline
  end

  def self.knife_bootstrap out, ip, options
    knife_stream(out, "bootstrap", options + [ ip ])
  end

  def self.knife_stream out, cmd, options=[]
    knife_cmd = "knife #{cmd} #{options.join(" ")}"
    out << "\nExecuting '#{knife_cmd}' \n\n"
    out.flush if out.respond_to?(:flush)
    status = nil
    IO.popen(knife_cmd + " 2>&1") do |o|
      while line = o.gets do
        out << line
        out.flush if out.respond_to?(:flush)
      end
      o.close
      status = $?.to_i
    end
    return status
  end

  def self.set_run_list node, list
    knife("node run_list set #{node} '#{list.join("','")}'")
  end

private
  def self.get_config
    File.join(ENV["HOME"], ".chef", "knife.rb")
  end
end
