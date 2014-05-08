# encoding: UTF-8
require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"

module Version2_0
  class NetworkRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Network routes initialized"
    end

    # Get list of networks for :provider
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* : array of strings
    #   - ec2:
    #   [
    #     {
    #       "cidr": "0.0.0.0/16",
    #       "vpcId": "vpc-1",
    #       "subnetId": "subnet-1",
    #       "name": "subnet-1",
    #       "zone": "us-east-1a"
    #     }
    #   ]
    #   - openstack:
    #   [
    #     {
    #       "cidr": "0.0.0.0/16",
    #       "name": "private",
    #       "id": "b14f8df9-ac27-48e2-8d65-f7ef78dc2654"
    #     }
    #   ]
    get "/networks/:provider" do
      check_headers :accept
      check_privileges("network", "r")
      check_provider(params[:provider])
      p = ::Version2_0::Provider::ProviderFactory.get params[:provider]
      json p.networks_detail
    end

  end
end
