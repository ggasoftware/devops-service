require "db/exceptions/invalid_record"
require "exceptions/invalid_command"
require "db/mongo/models/mongo_model"

#require "common/fog"

class User < MongoModel

  ROOT_USER_NAME = 'root'
  ROOT_PASSWORD = ''

  PRIVILEGES = ["r", "w", "rw", ""]

  attr_accessor :id, :password, :privileges, :email
  types :id => {:type => String, :empty => false},
        :email => {:type => String, :empty => false},
        :password => {:type => String, :empty => true}

  def initialize p={}
    self.id = p['username']
    self.email = p['email']
    self.password = p['password']
    self.privileges = p["privileges"] || self.default_privileges
  end

  def all_privileges
    privileges_with_value("rw")
  end

  def default_privileges
    privileges_with_value("r", "user" => "")
  end

  def grant cmd, priv=''
    raise InvalidCommand.new "Invalid privileges '#{priv}'. Available values are '#{PRIVILEGES.join("', '")}'" unless PRIVILEGES.include?(priv)
    raise InvalidCommand.new "Can't grant privileges to root" if self.id == ROOT_USER_NAME

    case cmd
    when "all"
      self.privileges.each_key do |key|
        self.privileges[key] = priv
      end
    when ""
      self.privileges = self.default_privileges
    else
      raise InvalidCommand.new "Unsupported command #{cmd}" unless self.all_privileges.include?(cmd)
      self.privileges[cmd] = priv
    end
  end

  def self.create_from_bson s
    user = User.new s
    user.id = s["_id"]
    user
  end

  def self.create_from_json json
    User.new( JSON.parse(json) )
  end

  def to_hash_without_id
    o = {
      "email" => self.email,
      "password" => self.password,
      "privileges" => self.privileges
    }
    o
  end

  def check_privilege cmd, priv
    p = self.privileges[cmd]
    return false if p.nil?
    return p.include?(priv)
  end

  def check_privilege_read cmd
    check_privilege_r_w cmd, "r"
  end

  def check_privilege_write cmd
    check_privilege_r_w cmd, "w"
  end

  def check_privilege_r_w cmd, flag
    p = self.privileges[cmd]
    return false if p.nil?
    return p == flag || p == 'rw'
  end

  def self.create_root
    root = User.new({'username' => ROOT_USER_NAME, 'password' => ROOT_PASSWORD})
    root.privileges = root.all_privileges
    root.email = "#{ROOT_USER_NAME}@host"
    root
  end

  private
  def privileges_with_value v, options={}
    {
      "flavor" => v,
      "group" => v,
      "image" => v,
      "project" => v,
      "server" => v,
      "key" => v,
      "user" => v,
      "filter" => v,
      "network" => v,
      "provider" => v,
      "script" => v,
      "templates" => v
    }.merge(options)
  end

end
