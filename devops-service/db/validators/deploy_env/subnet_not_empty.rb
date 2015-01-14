module Validators
  class DeployEnv::SubnetNotEmpty < Base

    def valid?
      !@model.subnets.empty?
    end

    def message
      'Subnets array can not be empty'
    end
  end
end