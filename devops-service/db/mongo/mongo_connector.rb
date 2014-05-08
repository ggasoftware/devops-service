require "mongo"

require "db/exceptions/record_not_found"
require "db/exceptions/invalid_record"
require "exceptions/invalid_privileges"

require "db/mongo/models/project"
require "db/mongo/models/image"
require "db/mongo/models/project"
require "db/mongo/models/server"
require "db/mongo/models/user"

include Mongo

class MongoConnector

  def initialize(db, host, port=27017, user=nil, password=nil)
    @mongo_client = MongoClient.new(host, port)
    @db = @mongo_client.db(db)
    @db.authenticate(user, password) unless user.nil? or password.nil?
    @projects = @db.collection("projects")
    @images = @db.collection("images")
    @servers = @db.collection("servers")
    @filters = @db.collection("filters")
    @keys = @db.collection("keys")
    @users = @db.collection("users")
    @statistic = @db.collection("statistic")
  end

  def images provider=nil
    q = (provider.nil? ? {} : {"provider" => provider})
    @images.find(q).to_a.map {|bi| Image.create_from_bson bi}
  end

  def image id
    i = @images.find(create_query("_id" => id)).to_a[0]
    raise RecordNotFound.new("Image '#{id}' does not exist") if i.nil?
    Image.create_from_bson i
  end

  def image_insert image
    image.validate!
    @images.insert(image.to_mongo_hash)
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: image with id '#{image.id}'")
    end
  end

  def image_update image
    image.validate!
    @images.update(create_query({"_id" => image.id}), create_query(image.to_mongo_hash))
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: image with id '#{image.id}'")
    end
  end

  def image_delete id
    r = @images.remove(create_query("_id" => id))
    raise RecordNotFound.new("Image '#{id}' not found") if r["n"] == 0
    r
  end

  def available_images provider
    f = @filters.find(create_query("type" => "image", "provider" => provider)).to_a[0]
    return [] if f.nil?
    f["images"]
  end

  def add_available_images images, provider
    return unless images.is_a?(Array)
    f = @filters.find(create_query("type" => "image", "provider" => provider)).to_a[0]
    if f.nil?
      @filters.insert(create_query({"type" => "image", "provider" => provider, "images" => images}))
      return images
    else
      f["images"] |= images
      @filters.update({"_id" => f["_id"]}, f)
      return f["images"]
    end
  end

  def delete_available_images images, provider
    return unless images.is_a?(Array)
    f = @filters.find(create_query("type" => "image", "provider" => provider)).to_a[0]
    unless f.nil?
      f["images"] -= images
      @filters.update({"_id" => f["_id"]}, f)
      return f["images"]
    end
    []
  end

  def is_project_exists? project
    self.project project.id
    return true
  rescue RecordNotFound => e
    return false
  end

  def project_insert project
    project.validate!
    @projects.insert(create_query(project.to_mongo_hash))
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: project with id '#{project.id}'")
    end
  end

  def project name
    p = @projects.find(create_query("_id" => name)).to_a[0]
    raise RecordNotFound.new("Project '#{name}' does not exist") if p.nil?
    Project.create_from_bson p
  end

  def projects_all
    p = @projects.find()
    p.to_a.map {|bp| Project.create_from_bson bp}
  end

  def projects list=nil, type=nil
    q = (list.nil? ? {} : {"_id" => {"$in" => list}})
    case type
    when :multi
      q["type"] = "multi"
    #else
    #  q["type"] = {"$exists" => false}
    end
    res = @projects.find(create_query(q))
    a = res.to_a
    a.map {|bp| Project.create_from_bson bp}
  end

  # names - array of project names
  def project_names_with_envs names=nil
    # db.projects.aggregate({$unwind:"$deploy_envs"}, {$project:{"deploy_envs.identifier":1}}, {$group:{_id:"$_id", envs: {$addToSet: "$deploy_envs.identifier"}}})
    q = []
    unless names.nil?
      q.push({
        "$match" => {
          "_id" => {
            "$in" => names
          }
        }
      })
    end
    q.push({
      "$unwind" =>  "$deploy_envs"
    })
    q.push({
      "$project" => {
        "deploy_envs.identifier" => 1
      }
    })
    q.push({
      "$group" => {
        "_id" => "$_id",
        "envs" => {
          "$addToSet" => "$deploy_envs.identifier"
        }
      }
    })
    res = @projects.aggregate(q)
    r = {}
    res.each do |ar|
      r[ar["_id"]] = ar["envs"]
    end
    return r
  end

  def projects_by_image image
    @projects.find(create_query("deploy_envs.image" => image)).to_a.map {|bp| Project.create_from_bson bp}
  end

  def projects_by_user user
    @projects.find(create_query("deploy_envs.users" => user)).to_a.map {|bp| Project.create_from_bson bp}
  end

  def project_delete name
    r = @projects.remove(create_query("_id" => name))
    raise RecordNotFound.new("Project '#{name}' not found") if r["n"] == 0
  end

  def project_update project
    project.validate!
    @projects.update(create_query({"_id" => project.id}), project.to_mongo_hash)
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: project with id '#{project.id}'")
    end
  end

  def servers p=nil, env=nil, names=nil
    q = {}
    q["project"] = p unless p.nil? or p.empty?
    q["deploy_env"] = env unless env.nil? or env.empty?
    q["chef_node_name"] = {"$in" => names} unless names.nil? or names.class != Array
    @servers.find(create_query(q)).to_a.map{|bs| Server.create_from_bson bs}
  end

  def servers_by_names names
    q = {}
    q["chef_node_name"] = {"$in" => names} unless names.nil? or names.class != Array
    @servers.find(create_query(q)).to_a.map{|bs| Server.create_from_bson bs}
  end

  def server_by_instance_id id
    find_server "_id" => id
  end

  def server_by_chef_node_name name
    find_server "chef_node_name" => name
  end

  def servers_by_key key_name
    @servers.find(create_query("key" => key_name)).to_a.map {|bs| Server.create_from_bson bs}
  end

  def server_insert s
    #s.validate!
    s.created_at = Time.now
    @servers.insert(create_query(s.to_mongo_hash))
  end

  def server_delete id
    @servers.remove(create_query("_id" => id))
  end

  def server_update server
    @servers.update({"_id" => server.id}, server.to_hash_without_id)
  end

  def keys
    @keys.find(create_query).to_a.map {|bi| Key.create_from_bson bi}
  end

  def key id, scope=nil
    q = {
      "_id" => id
    }
    q["scope"] = scope unless scope.nil?
    k = @keys.find(create_query(q)).to_a[0]
    raise RecordNotFound.new("Key '#{id}' does not exist") if k.nil?
    Key.create_from_bson k
  end

  def key_insert key
    key.validate!
    @keys.insert(create_query(key.to_mongo_hash))
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: key with id '#{key.id}'")
    end
  end

  def key_delete id
    r = @keys.remove(create_query("_id" => id, "scope" => Key::USER))
    raise RecordNotFound.new("Key '#{id}' not found") if r["n"] == 0
    r
  end

  def user_auth user, password
    u = @users.find("_id" => user, "password" => password).to_a[0]
    raise RecordNotFound.new("Invalid username or password") if u.nil?
  end

  def user id
    u = @users.find("_id" => id).to_a[0]
    raise RecordNotFound.new("User '#{id}' does not exist") if u.nil?
    User.create_from_bson u
  end

  def users array=nil
    q = {}
    q["_id"] = {"$in" => array} if array.is_a?(Array)
    @users.find(q).to_a.map {|bi| User.create_from_bson bi}
  end

  def users_names array=nil
    q = {}
    q["_id"] = {"$in" => array} if array.is_a?(Array)
    @users.find({}, :fields => ["_id"]).to_a.map{|u| u["_id"]}
  end

  def user_insert user
    user.validate!
    @users.insert(user.to_mongo_hash)
    rescue Mongo::OperationFailure => e
      if e.message =~ /^11000/
        raise InvalidRecord.new("Duplicate key error: user with id '#{user.id}'")
      end
  end

  def user_delete id
    r = @users.remove("_id" => id)
    raise RecordNotFound.new("User '#{id}' not found") if r["n"] == 0
    r
  end

  def user_update user
    user.validate!
    @users.update({"_id" => user.id}, user.to_mongo_hash)
  rescue Mongo::OperationFailure => e
    if e.message =~ /^11000/
      raise InvalidRecord.new("Duplicate key error: user with id '#{user.id}'")
    end
  end

  def create_root_user
    begin
      u = user("root")
    rescue RecordNotFound => e
      root = User.create_root
      @users.insert(root.to_mongo_hash)
    end
  end

  def check_user_privileges id, cmd, priv
    user = self.user(id)
    case priv
    when "r"
      raise InvalidPrivileges.new("Access denied for '#{user.id}'") unless user.check_privilege_read cmd
    when "w"
      raise InvalidPrivileges.new("Access denied for '#{user.id}'") unless user.check_privilege_write cmd
    else
      raise InvalidPrivileges.new("Access internal problem with privilege '#{priv}'")
    end
  end

  def check_project_auth project_id, env, user_id
    p = @projects.find(create_query("_id" => project_id)).to_a[0]
    raise RecordNotFound.new("Project '#{project_id}' does not exist") if p.nil?
    project = Project.create_from_bson p
    raise InvalidPrivileges.new("User '#{user_id}' unauthorized to work with project '#{project_id}'") unless project.check_authorization(user_id, env)
    project
  end

  def statistic user, path, method, body, response_code
    @statistic.insert({:user => user, :path => path, :method => method, :body => body, :response_code => response_code, :date => Time.now})
  end

private
  def find_server params
    s = @servers.find(create_query(params)).to_a[0]
    if s.nil?
      if params.has_key? "_id"
        raise RecordNotFound.new("No server by instance id '#{params["_id"]}' found")
      elsif params.has_key? "chef_node_name"
        raise RecordNotFound.new("No server by node name '#{params["chef_node_name"]}' found")
      end
    end
    Server.create_from_bson s
  end

  def create_query q={}
    q
  end

  def create_query_with_provider provider, q={}
    q["provider"] = provider
    q
  end
end
