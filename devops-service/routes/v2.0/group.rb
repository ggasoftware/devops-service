# encoding: UTF-8
require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"

module Version2_0
  class GroupRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Group routes initialized"
    end

    # Get security groups for :provider
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   - ec2:
    #   {
    #     "default": {
    #       "description": "default group",
    #       "id": "sg-565cf93f",
    #       "rules": [
    #         {
    #           "protocol": "tcp",
    #           "from": 22,
    #           "to": 22,
    #           "cidr": "0.0.0.0/0"
    #         }
    #       ]
    #     }
    #   }
    #   - openstack:
    #   {
    #     "default": {
    #       "description": "default",
    #       "rules": [
    #         {
    #           "protocol": null,
    #           "from": null,
    #           "to": null,
    #           "cidr": null
    #         }
    #       ]
    #     }
    #   }
    # TODO: vpc support for ec2
    get "/groups/:provider" do
      check_headers :accept
      check_privileges("group", "r")
      check_provider(params[:provider])
      p = ::Version2_0::Provider::ProviderFactory.get params[:provider]
      json p.groups(params)
    end

  end
end
