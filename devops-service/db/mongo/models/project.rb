require "db/exceptions/invalid_record"
require "db/exceptions/record_not_found"
require "db/mongo/models/deploy_env"
require "db/mongo/models/user"
require "db/mongo/models/deploy_env_multi"
require "db/mongo/models/mongo_model"
require "json"

class Project < MongoModel

  attr_accessor :id, :deploy_envs, :type

  types :id => {:type => String, :empty => false},
        :deploy_envs => {:type => Array, :value_type => false, :empty => false}

  MULTI_TYPE = "multi"

  def self.fields
    ["deploy_envs", "type"]
  end

  def initialize p={}
    self.id = p["name"]
    #raise InvalidRecord.new "No deploy envirenments for project #{self.id}" if p["deploy_envs"].nil? or p["deploy_envs"].empty?
    self.type = p["type"]
    env_class = ( self.multi? ? DeployEnvMulti : DeployEnv )
    unless p["deploy_envs"].nil?
      self.deploy_envs = []
      p["deploy_envs"].each do |e|
        env = env_class.create(e)
        self.deploy_envs.push env
      end
    end
  end

  def deploy_env env
    de = self.deploy_envs.detect {|e| e.identifier == env}
    raise RecordNotFound.new("Project '#{self.id}' does not have deploy environment '#{env}'") if de.nil?
    de
  end

  def add_authorized_user user, env=nil
    return if user.nil?
    new_users = ( user.is_a?(Array) ? user : [ user ] )
    if env.nil?
      self.deploy_envs.each do |e|
        return unless e.users.is_a?(Array)
        e.users = (e.users + new_users).uniq
      end
    else
      e = self.deploy_env(env)
      return unless e.users.is_a?(Array)
      e.users = (e.users + new_users).uniq
    end
  end

  def remove_authorized_user user, env=nil
    return if user.nil?
    users = ( user.is_a?(Array) ? user : [ user ] )
    if env.nil?
      self.deploy_envs.each do |e|
        return unless e.users.is_a?(Array)
        e.users = e.users - users
      end
    else
      e = self.deploy_env(env)
      return unless e.users.is_a?(Array)
      e.users = e.users - users
    end
  end

  def check_authorization user_id, env
    e = self.deploy_env(env)
    return true if user_id == User::ROOT_USER_NAME
    return e.users.include? user_id
  rescue RecordNotFound => e
    return false
  end

  def validate!
    super
    check_name_value(self.id)
    envs = self.deploy_envs.map {|d| d.identifier}
    non_uniq = envs.uniq.select{|u| envs.count(u) > 1}
    raise InvalidRecord.new "Deploy environment(s) '#{non_uniq.join("', '")}' is/are not unique" unless non_uniq.empty?
    self.deploy_envs.each do |d|
      d.validate!
      unless self.multi?
        rn = "#{self.id}#{DevopsService.config[:role_separator] || "_"}#{d.identifier}"
        role = "role[#{rn}]"
        d.run_list = d.run_list - [rn, role]
        d.run_list.unshift(role)
      end
    end

    true
  rescue InvalidRecord, ArgumentError => e
    raise InvalidRecord.new "Project '#{self.id}'. #{e.message}"
  end

  def remove_env env
    self.deploy_envs.delete_if {|e| e.identifier == env}
  end

  def add_env env
    raise InvalidRecord.new "Deploy environment '#{env.identifier}' for project '#{self.id}' already exist" unless self.deploy_env(env.identifier).nil?
    self.deploy_envs.push env
  end

  def to_hash
    h = self.to_hash_without_id
    h["name"] = self.id
    h
  end

  def to_hash_without_id
    h = {}
    h["deploy_envs"] = self.deploy_envs.map {|e| e.to_hash} unless self.deploy_envs.nil?
    if self.multi?
      h["type"] = MULTI_TYPE
    end
    h
  end

  def multi?
    self.type == MULTI_TYPE
  end

  def self.create_from_bson p
    p["name"] = p["_id"]
    Project.new p
  end

end
