require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"
require "commands/bootstrap_templates"

module Version2_0
  class BootstrapTemplatesRoutes < BaseRoutes

    include BootstrapTemplatesCommands

    def initialize wrapper
      super wrapper
      puts "Bootstrap templates routes initialized"
    end

    # Get list of available bootstrap templates
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* : array of strings
    #   [
    #     "omnibus"
    #   ]
    get "/templates" do
      check_headers :accept
      check_privileges("templates", "r")
      json get_templates
    end

  end
end

