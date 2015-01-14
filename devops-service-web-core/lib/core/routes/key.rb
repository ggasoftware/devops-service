module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Key
          
          def self.registered(app)

            add = lambda do
              submit { |http| http.post(host + '/v2.0/key', params) }
            end

           app.post '/key', &add

          end
      
        end
      end
    end
  end
end
