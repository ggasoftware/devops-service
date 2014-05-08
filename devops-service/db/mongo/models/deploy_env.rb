require "db/mongo/models/mongo_model"
require "db/exceptions/invalid_record"
require "providers/provider_factory"
require "commands/deploy_env"

class DeployEnv < MongoModel

  include DeployEnvCommands

  attr_accessor :identifier, :flavor, :image, :run_list, :subnets, :expires, :provider, :groups, :users

  types :identifier => {:type => String, :empty => false},
        :image => {:type => String, :empty => false},
        :flavor => {:type => String, :empty => false},
        :provider => {:type => String, :empty => false},
        :expires => {:type => String, :empty => false, :nil => true},
        :run_list => {:type => Array, :empty => true},
        :users => {:type => Array, :empty => true},
        :subnets => {:type => Array, :empty => true},
        :groups => {:type => Array, :empty => false}

  def initialize d={}
    self.identifier = d["identifier"]
    self.flavor = d["flavor"]
    self.image = d["image"]
    b = d["subnets"] || []
    self.subnets = (b.is_a?(Array) ? b.uniq : b)
    b = d["run_list"] || []
    self.run_list = (b.is_a?(Array) ? b.uniq : b)
    self.expires = d["expires"]
    self.provider = d["provider"]
    b = d["groups"] || ["default"]
    self.groups = (b.is_a?(Array) ? b.uniq : b)
    b = d["users"] || []
    self.users = (b.is_a?(Array) ? b.uniq : b)
  end

  def validate!
    super
    e = DeployEnv.validate_run_list(self.run_list)
    raise InvalidRecord.new "Invalid run list elements: '#{e.join("', '")}'" unless e.empty?

    unless self.expires.nil?
      check_expires!(self.expires)
    end

    p = ::Version2_0::Provider::ProviderFactory.get(self.provider)
    check_flavor!(p, self.flavor)
    check_image!(p, self.image)
    check_subnets_and_groups!(p, self.subnets, self.groups)
    check_users!(self.users)

    true
  rescue InvalidRecord => e
    raise InvalidRecord.new "Deploy environment '#{self.identifier}'. " + e.message
  end

  def to_hash
    {
      "flavor" => self.flavor,
      "identifier" => self.identifier,
      "image" => self.image,
      "run_list" => self.run_list,
      "subnets" => self.subnets,
      "expires" => self.expires,
      "provider" => self.provider,
      "groups" => self.groups,
      "users" => self.users
    }
  end

  def self.create_from_bson d
    DeployEnv.new(d)
  end

  def self.create hash
    DeployEnv.new(hash)
  end

  def self.validate_run_list list
    rl = /\Arole|recipe\[[\w-]+(::[\w-]+)?\]\Z/
    list.select {|l| (rl =~ l).nil?}
  end

end
