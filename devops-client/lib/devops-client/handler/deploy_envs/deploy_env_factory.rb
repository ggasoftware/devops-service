require "devops-client/handler/deploy_envs/deploy_env_static"
require "devops-client/handler/deploy_envs/deploy_env_ec2"
require "devops-client/handler/deploy_envs/deploy_env_openstack"

class DeployEnvFactory

  @@envs = {}

  def self.create provider, host, options, auth
    unless @@envs.key?(provider)
      de = case provider
      when DeployEnvStatic::NAME
        DeployEnvStatic
      when DeployEnvEc2::NAME
        DeployEnvEc2
      when DeployEnvOpenstack::NAME
        DeployEnvOpenstack
      else

      end
      @@envs[provider] = de.new(host, options, auth)
    end
    @@envs[provider]
  end

end
