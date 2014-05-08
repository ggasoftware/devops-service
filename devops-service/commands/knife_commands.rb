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

  def self.create_role project, env
    file = "/tmp/new_role.json"
    File.open(file, "w") do |f|
      f.puts <<-EOH
{
  "name" : "#{project}_#{env}",
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
    raise "Cannot create role '#{project}_#{env}': #{out}" unless $?.success?
    true
  end

  def self.roles
    o, s = knife("role list --format json")
    return (s ? JSON.parse(o) : nil)
  end

  def self.knife cmd
    o = `knife #{cmd} 2>&1`
    return o, $?.success?
  end

end
