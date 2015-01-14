module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Server
          
          def self.registered(app)

            add = lambda do
              logger.info "Server -> Add with params: #{params}"
              req = params
              api_call('/server/add', method: :post, data: req.to_json)
            end

            bootstrap = lambda do
              logger.info "Server -> Add with params: #{params}"
              req = params
              req["bootstrap_template"] = "omnibus"
              api_call('/server/bootstrap', method: :post, data: req.to_json)
            end

            create = lambda do
              logger.info "Server -> Create with params: #{params}"
              data = params
              data['name'] = nil if params['name'].empty?
              data['without_bootstrap'] = (params['without_bootstrap'] == 'on' ? true : nil)
              data['force'] = (params['force'] == 'on' ? true : nil)
              req = data
              api_call('/server', method: :post, data: req.to_json)
            end

            deploy = lambda do
              logger.info "Server -> Deploy with params: #{params}"
              req = { "names" => [params["names"]] }
              api_call("/deploy", method: :post, data: req.to_json)
            end

            pause = lambda do
              api_call("/server/#{params[:node_name]}/pause", method: :post)
            end

            unpause = lambda do
              api_call("/server/#{params[:node_name]}/unpause", method: :post)
            end

            reserve = lambda do
              api_call("/server/#{params[:node_name]}/reserve", method: :post)
            end

            unreserve = lambda do
              api_call("/server/#{params[:node_name]}/unreserve", method: :post)
            end

            delete = lambda do
              key = params["key"] if params["key"]
              req = { "key" => key }
              api_call("/server/#{params[:name]}", method: :delete, data: req.to_json)
            end
              
            app.post '/server/add', &add
            app.post '/server/bootstrap', &bootstrap
            app.post '/server/create', &create
            app.post '/server/deploy', &deploy
            app.post '/server/:node_name/pause', &pause
            app.post '/server/:node_name/unpause', &unpause
            app.post '/server/:node_name/reserve', &reserve
            app.post '/server/:node_name/unreserve', &unreserve
            app.delete '/server/:name/delete', &delete
            
          end
      
        end
      end
    end
  end
end
