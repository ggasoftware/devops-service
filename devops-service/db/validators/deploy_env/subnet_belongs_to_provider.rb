module Validators
  class DeployEnv::SubnetBelongsToProvider < Base

    def valid?
      provider_subnets = @model.provider_instance.networks.map { |n| n["name"] }
      @invalid_subnets = @model.subnets - provider_subnets
      @invalid_subnets.empty?
    end

    def message
      "Invalid subnets '#{@invalid_subnets.join("', '")}'."
    end
  end
end