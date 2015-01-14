module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Extra
          
          def self.registered(app)

            app_options = lambda do
              get_app_options.to_json
            end
  
            app.get '/app/options', &app_options

          end
      
        end
      end
    end
  end
end
