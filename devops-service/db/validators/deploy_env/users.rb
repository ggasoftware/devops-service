module Validators
  class DeployEnv::Users < Base

    def valid?
      mongo_users = DevopsService.mongo.users_names(@model.users)
      @nonexistent_users = @model.users - mongo_users
      @nonexistent_users.empty?
    end

    def message
      "These users are missing in mongo: '#{@nonexistent_users.join("', '")}'."
    end
  end
end