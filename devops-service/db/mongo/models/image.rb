require "db/exceptions/invalid_record"
require "db/mongo/models/mongo_model"
require "commands/image"
require "commands/bootstrap_templates"

class Image < MongoModel

  include ImageCommands
  include BootstrapTemplatesCommands

  attr_accessor :id, :provider, :remote_user, :name, :bootstrap_template
  types :id => {:type => String, :empty => false},
        :provider => {:type => String, :empty => false},
        :remote_user => {:type => String, :empty => false},
        :name => {:type => String, :empty => true},
        :bootstrap_template => {:type => String, :empty => false, :nil => true}

  def validate!
    super
    images = get_images(DevopsService.mongo, self.provider)
    raise InvalidRecord.new "Invalid image id '#{self.id}' for provider '#{self.provider}', please check image filters" unless images.map{|i| i["id"]}.include?(self.id)

    if self.bootstrap_template
      templates = get_templates
      raise InvalidRecord.new "Invalid bootstrap template '#{self.bootstrap_template}' for image '#{self.id}'" unless templates.include?(self.bootstrap_template)
    end
  end

  def initialize p={}
    self.id = p["id"]
    self.provider = p["provider"]
    self.remote_user = p["remote_user"]
    self.name = p["name"] || ""
    self.bootstrap_template = p["bootstrap_template"]
  end

  def self.create_from_bson args
    image = Image.new(args)
    image.id = args["_id"]
    image
  end

  def to_hash_without_id
    o = {
      "provider" => self.provider,
      "name" => self.name,
      "remote_user" => self.remote_user
    }
    o["bootstrap_template"] = self.bootstrap_template
    o
  end

  def self.create_from_json! json
    Image.new( JSON.parse(json) )
  end

end
