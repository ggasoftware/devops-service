require "db/mongo/models/deploy_env_base"
require "providers/provider_factory"

class DeployEnvEc2 < DeployEnvBase

  attr_accessor :flavor, :image, :subnets, :groups

  types :identifier => {:type => String, :empty => false},
        :image => {:type => String, :empty => false},
        :flavor => {:type => String, :empty => false},
        :provider => {:type => String, :empty => false},
        :expires => {:type => String, :empty => false, :nil => true},
        :run_list => {:type => Array, :empty => true},
        :users => {:type => Array, :empty => true},
        :subnets => {:type => Array, :empty => true},
        :groups => {:type => Array, :empty => false}

  set_validators  ::Validators::DeployEnv::RunList,
                  ::Validators::DeployEnv::Expiration,
                  ::Validators::DeployEnv::Users,
                  ::Validators::DeployEnv::Flavor,
                  ::Validators::DeployEnv::Image,
                  ::Validators::DeployEnv::SubnetBelongsToProvider,
                  ::Validators::DeployEnv::Groups

  def initialize d={}
    super(d)
    self.flavor = d["flavor"]
    self.image = d["image"]
    b = d["subnets"] || []
    self.subnets = if b.is_a?(Array)
      (b.size > 1 ? [ b[0] ] : b)
    else
      b
    end
    b = d["groups"] || ["default"]
    self.groups = (b.is_a?(Array) ? b.uniq : b)
  end

  def to_hash
    h = super
    h.merge!({
      "flavor" => self.flavor,
      "image" => self.image,
      "subnets" => self.subnets,
      "groups" => self.groups
    })
  end

  def self.create hash
    DeployEnvEc2.new(hash)
  end

  private

  def subnets_filter
    networks = provider_instance.networks

    unless self.subnets.empty?
      {"vpc-id" => networks.detect{|n| n["name"] == self.subnets[0]}["vpcId"] }
    end
  end

end
