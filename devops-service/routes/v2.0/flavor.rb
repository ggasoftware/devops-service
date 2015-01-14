require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"

module Version2_0
  class FlavorRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Flavor routes initialized"
    end

    # Get list of flavors for :provider
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* : array of objects
    #   - ec2:
    #   [
    #     {
    #       "id": "t1.micro",
    #       "cores": 2,
    #       "disk": 0,
    #       "name": "Micro Instance",
    #       "ram": 613
    #     }
    #   ]
    #   - openstack:
    #   [
    #     {
    #       "id": "m1.small",
    #       "v_cpus": 1,
    #       "ram": 2048,
    #       "disk": 20
    #     }
    #   ]
    get "/flavors/:provider" do
      check_headers :accept
      check_privileges("flavor", "r")
      check_provider(params[:provider])
      p = ::Provider::ProviderFactory.get params[:provider]
      json p.flavors
    end

  end
end
