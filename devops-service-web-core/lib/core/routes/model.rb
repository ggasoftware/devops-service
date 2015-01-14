module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Model
          
          def self.registered(app)

            get = lambda do
              api_call("/#{params[:model]}/#{params[:id]}")
            end

            delete = lambda do
              api_call("/#{params[:model]}/#{params[:id]}", method: :delete)
            end

            app.get '/models/:model/:id', &get
            app.delete '/models/:model/:id', &delete

          end
      
        end
      end
    end
  end
end
