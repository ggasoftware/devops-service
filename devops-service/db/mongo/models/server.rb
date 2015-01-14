require "db/exceptions/invalid_record"
require "db/mongo/models/mongo_model"

class Server < MongoModel

  attr_accessor :provider, :chef_node_name, :id, :remote_user, :project, :deploy_env, :private_ip, :public_ip, :created_at, :without_bootstrap, :created_by, :reserved_by
  attr_accessor :options, :static, :key

  types :id => {:type => String, :empty => false},
        :provider => {:type => String, :empty => false},
        :remote_user => {:type => String, :empty => false},
        :project => {:type => String, :empty => false},
        :deploy_env => {:type => String, :empty => false},
        :private_ip => {:type => String, :empty => false},
        :public_ip => {:type => String, :empty => true, :nil => true},
        :key => {:type => String, :empty => false},
        :created_by => {:type => String, :empty => false},
        :chef_node_name => {:type => String, :empty => true},
        :reserved_by => {:type => String, :empty => true}

  def self.fields
    ["chef_node_name", "project", "deploy_env", "provider", "remote_user", "private_ip", "public_ip", "created_at", "created_by", "static", "key", "reserved_by"]
  end

  def initialize s={}
    self.provider = s["provider"]
    self.chef_node_name = s["chef_node_name"]
    self.id = s["_id"]
    self.remote_user = s["remote_user"]
    self.project = s["project"]
    self.deploy_env = s["deploy_env"]
    self.public_ip = s["public_ip"]
    self.private_ip = s["private_ip"]
    self.created_at = s["created_at"]
    self.created_by = s["created_by"]
    self.static = s["static"]
    self.key = s["key"]
    self.reserved_by = s["reserved_by"]
  end

  def validate!
    super
    true
  end

  def to_hash_without_id
    {
      "provider" => self.provider,
      "chef_node_name" => self.chef_node_name,
      "remote_user" => self.remote_user,
      "project" => self.project,
      "deploy_env" => self.deploy_env,
      "private_ip" => self.private_ip,
      "public_ip" => self.public_ip,
      "created_at" => self.created_at,
      "created_by" => self.created_by,
      "static" => self.static,
      "key" => self.key,
      "reserved_by" => self.reserved_by
    }.delete_if{|k,v| v.nil?}
  end

  def to_list_hash
    {
      "id" => self.id,
      "chef_node_name" => self.chef_node_name
    }
  end

  def self.create_from_bson s
    Server.new(s)
  end

  def info
    str = "Instance Name: #{self.chef_node_name}\n"
    str << "Instance ID: #{self.id}\n"
    str << "Private IP: #{self.private_ip}\n"
    str << "Public IP: #{self.public_ip}\n" unless self.public_ip.nil?
    str << "Remote user: #{self.remote_user}\n"
    str << "Project: #{self.project} - #{self.deploy_env}\n"
    str << "Created by: #{self.created_by}"
    str
  end

  def static?
    self.static || false
  end

end
