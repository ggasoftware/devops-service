module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Collection
          
          def self.registered(app)

            collection = lambda do
              if params[:provider].nil?
                api_call("/#{params[:name]}")
              else
                api_call("/#{params[:name]}/#{params[:provider]}")
              end
            end

            app.get '/collections/:name/?:provider?', &collection

          end
      
        end
      end
    end
  end
end
