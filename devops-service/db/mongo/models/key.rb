require "db/exceptions/invalid_record"
require "db/mongo/models/mongo_model"
require "json"

class Key < MongoModel

  SYSTEM = "system"
  USER = "user"

  attr_accessor :id, :path, :scope
  types :id => {:type => String, :empty => false},
        :path => {:type => String, :empty => false},
        :scope => {:type => String, :empty => false}

  def initialize p={}
    self.id = p["id"]
    self.path = p["path"]
    self.scope = p["scope"] || USER
  end

  def self.create_from_bson s
    key = Key.new s
    key.id = s["_id"]
    key
  end

  def self.create_from_json json
    Key.new( JSON.parse(json) )
  end

  def filename
    File.basename(self.path)
  end

  def to_hash_without_id
    o = {
      "path" => self.path,
      "scope" => self.scope
    }
    o
  end

  def validate!
    super
    raise InvalidRecord.new "File does not exist" unless File.exist?(self.path)
    raise InvalidRecord.new "Key parameter 'scope' is invalid" unless [SYSTEM, USER].include?(self.scope)
    true
  end

end
