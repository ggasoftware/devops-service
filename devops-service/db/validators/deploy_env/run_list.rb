# Use helper to avoid code duplication: we have run_list validation in server routes,
# not only in deploy env model

module Validators
  class DeployEnv::RunList < Base

    def initialize(model)
      super(model)
      @helper_validator = Helpers::RunList.new(@model.run_list)
    end

    def valid?
      @helper_validator.valid?
    end

    def message
      @helper_validator.message
    end
  end
end