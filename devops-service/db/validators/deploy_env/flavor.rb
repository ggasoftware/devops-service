module Validators
  class DeployEnv::Flavor < Base

    def valid?
      @model.provider_instance.flavors.detect do |flavor|
        flavor['id'] == @model.flavor
      end
    end

    def message
      "Invalid flavor '#{@model.flavor}'."
    end
  end
end