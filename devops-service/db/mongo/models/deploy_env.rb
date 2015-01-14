require "db/exceptions/invalid_record"
require "db/mongo/models/deploy_env_static"
require "db/mongo/models/deploy_env_openstack"
require "db/mongo/models/deploy_env_ec2"
require "providers/static"
require "providers/openstack"
require "providers/ec2"

class DeployEnv

  def self.create hash
    c = case(hash["provider"])
    when ::Provider::Static::PROVIDER
      DeployEnvStatic
    when ::Provider::Ec2::PROVIDER
      DeployEnvEc2
    when ::Provider::Openstack::PROVIDER
      DeployEnvOpenstack
    else
      raise InvalidRecord.new "Invalid provider '#{hash["provider"]}' for deploy envirenment '#{hash["identifier"]}'"
    end
    c.new(hash)
  end

end
