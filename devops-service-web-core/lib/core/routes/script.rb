module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Script
          
          def self.registered(app)

            run = lambda do
              req = {"nodes" => params["nodes"], "params" => params["params"]}
              api_call("/script/run/#{params["script_id"]}", method: :post, data: JSON.pretty_generate(req))
            end

            add = lambda do
              submit do |http|
                http.put(host + '/v2.0/script/' + params[:script_name], params[:content], json_headers)
              end
            end

            app.post '/script/run/:script_id', &run
            app.put '/script', &add

          end
      
        end
      end
    end
  end
end
