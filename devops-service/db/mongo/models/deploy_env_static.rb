require "db/mongo/models/deploy_env_base"

class DeployEnvStatic < DeployEnvBase

  types :identifier => {:type => String, :empty => false},
        :provider => {:type => String, :empty => false},
        :expires => {:type => String, :empty => false, :nil => true},
        :run_list => {:type => Array, :empty => true},
        :users => {:type => Array, :empty => true}

  set_validators  ::Validators::DeployEnv::RunList,
                  ::Validators::DeployEnv::Expiration,
                  ::Validators::DeployEnv::Users

  def initialize d={}
    super(d)
=begin
    self.identifier = d["identifier"]
    b = d["run_list"] || []
    self.run_list = (b.is_a?(Array) ? b.uniq : b)
    self.expires = d["expires"]
    self.provider = d["provider"]
    b = d["users"] || []
    self.users = (b.is_a?(Array) ? b.uniq : b)
=end
  end

  def to_hash
    super
=begin
    {
      "identifier" => self.identifier,
      "run_list" => self.run_list,
      "expires" => self.expires,
      "provider" => self.provider,
      "users" => self.users
    }
=end
  end

  def self.create hash
    DeployEnvStatic.new(hash)
  end

end
