module Validators
  class DeployEnv::Groups < Base

    def valid?
      subnets_filter = @model.send(:subnets_filter)
      @invalid_groups = @model.groups - @model.provider_instance.groups(subnets_filter).keys
      @invalid_groups.empty?
    end

    def message
      "Invalid groups '#{@invalid_groups.join("', '")}'."
    end
  end
end