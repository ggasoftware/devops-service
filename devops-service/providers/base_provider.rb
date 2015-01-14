require "fog"

module Provider
  class BaseProvider

    attr_accessor :ssh_key, :certificate_path, :connection_options, :run_list

    protected
    def connection_compute options
      Fog::Compute.new( options )
    end

    def connection_network options
      Fog::Network.new( options )
    end

    def configured?
      !(empty_param?(self.ssh_key) or empty_param?(self.certificate_path))
    end

    def empty_param? param
      param.nil? or param.empty?
    end

  end
end
