require "devops-client/handler/deploy_envs/deploy_env"

class DeployEnvStatic < DeployEnv

  NAME = "static"

  def initialize host, options, auth
    @host = host
    self.auth = auth
    self.options = options
  end

  def provider
    NAME
  end

  def fill obj
    super(obj)
  end

end
