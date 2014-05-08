module Version2_0
  module Provider
    class ProviderFactory

      @@providers = nil

      def self.providers
        @@providers.keys
      end

      def self.get provider
        p = @@providers[provider]
        raise ::Sinatra::NotFound.new("Provider #{provider} not found") if p.nil?
        p
      end

      def self.all
        if @@providers.nil?
          ProviderFactory.init
        end
        @@providers.values
      end

      def self.init
        conf = DevopsService.config
        @@providers = {}
        ["ec2", "openstack"].each do |p|
          begin
            require "providers/#{p}"
            o = Version2_0::Provider.const_get(p.capitalize).new(conf)
            @@providers[p] = o if o.configured?
          rescue => e
            next
          rescue LoadError
            next
          end
        end
      end

    end
  end
end
