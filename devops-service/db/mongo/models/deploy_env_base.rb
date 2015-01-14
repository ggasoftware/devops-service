require "db/mongo/models/mongo_model"
require "db/exceptions/invalid_record"
require "commands/deploy_env"

class DeployEnvBase < MongoModel

  include DeployEnvCommands

  attr_accessor :identifier, :run_list, :expires, :provider, :users

  def initialize d={}
    self.identifier = d["identifier"]
    b = d["run_list"] || []
    self.run_list = (b.is_a?(Array) ? b.uniq : b)
    self.expires = d["expires"]
    self.provider = d["provider"]
    b = d["users"] || []
    self.users = (b.is_a?(Array) ? b.uniq : b)
  end

  def validate!
    super
    begin
      self.class.validators.each do |validator|
        validator.new(self).validate!
      end
      true
    rescue InvalidRecord => e
      raise InvalidRecord.new "Deploy environment '#{self.identifier}'. " + e.message
    end
  end

  def to_hash
    {
      "identifier" => self.identifier,
      "run_list" => self.run_list,
      "expires" => self.expires,
      "provider" => self.provider,
      "users" => self.users
    }
  end

  def provider_instance
    @provider_instance ||= ::Provider::ProviderFactory.get(self.provider)
  end


  # class methods
  class << self

    def validators
      @validators
    end

    private

    def set_validators(*validators)
      @validators = validators
    end

  end

end
