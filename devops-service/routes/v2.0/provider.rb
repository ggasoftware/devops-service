# encoding: UTF-8
require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"

module Version2_0
  class ProviderRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Provider routes initialized"
    end

    # Get devops providers
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     "ec2",
    #     "openstack"
    #   ]
    get "/providers" do
      check_headers :accept
      check_privileges("provider", "r")
      json ::Provider::ProviderFactory.providers
    end

  end
end
