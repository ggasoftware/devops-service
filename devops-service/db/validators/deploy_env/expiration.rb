module Validators
  class DeployEnv::Expiration < Base

    def valid?
      if @model.expires
        @model.expires.match(/^[0-9]+[smhdw]$/)
      else
        true
      end
    end

    def message
      "Parameter 'expires' is invalid. Valid format: [0-9]+[smhdw] or null."
    end
  end
end