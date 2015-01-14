require "sinatra"

module Provider
  class ProviderFactory

    @@providers = {}

    def self.providers
      @@providers.keys
    end

    def self.get provider
      p = @@providers[provider]
      raise ::Sinatra::NotFound.new("Provider #{provider} not found") if p.nil?
      p
    end

    def self.all
      @@providers.values
    end

    def self.init conf
      ["ec2", "openstack", "static"].each do |p|
        begin
          require "providers/#{p}"

          if File.exist?("providers/#{p}_stub.rb")
            require "providers/#{p}_stub"
          end

          o = Provider.const_get(p.capitalize).new(conf)
          if o.configured?
            @@providers[p] = o
            puts "Provider '#{p}' has been loaded"
          end
        rescue => e
          puts "Error while loading provider '#{p}': " + e.message
          next
        rescue LoadError => e
          puts "Can not load provider '#{p}': " + e.message
          next
        end
      end
    end

  end
end
