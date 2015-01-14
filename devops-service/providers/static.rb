require "providers/base_provider"
require "commands/server"

module Provider
  class Static < BaseProvider
    PROVIDER = "static"

    def initialize config
      self.certificate_path = config[:static_certificate]
      self.ssh_key = "static"
      @@mongo ||= MongoConnector.new(config[:mongo_db], config[:mongo_host], config[:mongo_port], config[:mongo_user], config[:mongo_password])
    end

    def configured?
      true
    end

    def name
      PROVIDER
    end

    def flavors
      []
    end

    def groups filter=nil
      {}
    end

    def images filters
      []
    end

    def networks
      []
    end

    def networks_detail
      self.networks
    end

    def servers
      @@mongo.servers_find({:provider => PROVIDER}).map{|s| s.to_hash}
    end

    def create_default_chef_node_name s
      "static-#{s.project}-#{s.deploy_env}-#{Time.now.to_i}"
    end

    def create_server s, out
      out << "Unsupported operation: ca not create server for provider 'static'"
      false
    end

    def delete_server s
      cert = @@mongo.key(s.key).path
      res = ::ServerCommands.unbootstrap(s, cert)
      m = "Static server with id '#{s.id}' and name '#{s.chef_node_name}' "
      return m + (res.nil? ? "has been unbootstraped" : "can not be unbootstraped: #{res}")
    end

    def pause_server s
      nil
    end

    def unpause_server s
      nil
    end

  end
end
