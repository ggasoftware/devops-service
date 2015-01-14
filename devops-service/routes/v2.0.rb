require "routes/v2.0/flavor"
require "routes/v2.0/image"
require "routes/v2.0/filter"
require "routes/v2.0/network"
require "routes/v2.0/group"
require "routes/v2.0/deploy"
require "routes/v2.0/project"
require "routes/v2.0/key"
require "routes/v2.0/user"
require "routes/v2.0/provider"
require "routes/v2.0/tag"
require "routes/v2.0/server"
require "routes/v2.0/script"
require "routes/v2.0/status"
require "routes/v2.0/bootstrap_templates"

module Version2_0
  class V2_0

    # Initialize modules of devops API v2.0
    def initialize app
      stack = Rack::Builder.new
      [FlavorRoutes, ImageRoutes, FilterRoutes, NetworkRoutes, GroupRoutes, DeployRoutes,
       ProjectRoutes, KeyRoutes, UserRoutes, ProviderRoutes, TagRoutes, ServerRoutes, ScriptRoutes, BootstrapTemplatesRoutes, StatusRoutes].each do |m|
        stack.use m
      end
      stack.run app
      @app = stack.to_app
    end

    def call(env)
      @app.call env
    end
  end
end
