require "json"
require "routes/v2.0/base_routes"
require "providers/provider_factory"

module Version2_0
  class BootstrapTemplatesRoutes < BaseRoutes

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
      res = []
      Dir.foreach("#{ENV["HOME"]}/.chef/bootstrap/") {|f| res.push(f[0..-5]) if f.end_with?(".erb")} if File.exists? "#{ENV["HOME"]}/.chef/bootstrap/"
      json res
    end

  end
end

