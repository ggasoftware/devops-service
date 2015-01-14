module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Project
          
          def self.registered(app)

            deploy = lambda do
              logger.info "Project -> Deploy with params: #{params}"
              req = {}
              if params["servers"]
                req["servers"] = params["servers"]
              end
              if params["deploy_env"]
                req["deploy_env"] = params["deploy_env"]
              end
              api_call("/project/#{params['project_id']}/deploy", method: :post, data: req.to_json)
            end

            create = lambda do
              params = JSON.parse(request.body.read)
              api_call('/project', method: :post, data: JSON.pretty_generate(params))
            end

            request_project = lambda do
              params = JSON.parse(request.body.read)
              api_call('/request/project', method: :post, data: JSON.pretty_generate(params))
            end

            update = lambda do
              params = JSON.parse(request.body.read)
              puts params
              api_call("/project/#{params['name']}", method: :put, data: JSON.pretty_generate(params))
            end

            get_projects = lambda do
              api_call("/projects?fields[]=deploy_envs")
            end

            requests = lambda do
              api_call("/requests")
            end

            requests_count = lambda do
              api_call("/requests/count")
            end

            apply_request = lambda do
              id = params[:request_id]
              api_call("/request/#{id}/apply", method: :post)
            end

            get_project_servers = lambda do
              api_call("/project/#{params[:project_id]}/servers")
            end

            add_user = lambda do
              req = {}
              req['deploy_env'] = params[:deploy_env] unless params[:deploy_env] == ''
              req['users'] = params[:users].split(',')
              req['users'].each do |user|
                user.lstrip!
                user.rstrip!
              end
              api_call("/project/#{params[:project]}/user", method: :put, data: JSON.pretty_generate(req))
            end

            delete_user = lambda do
              req = {'users' => params[:users]}
              req['deploy_env'] = params[:deploy_env] unless params[:deploy_env] == ''
              api_call("/project/#{params[:project]}/user", method: :delete, data: JSON.pretty_generate(req))
            end

            env_users = lambda do
              if !params[:deploy_env].nil?
                res = api_call("/project/#{params[:project]}")
                res_json = JSON.parse res
                res_json['deploy_envs'].each do |env|
                  if env['identifier'] == params[:deploy_env]
                    return JSON.pretty_generate env['users']
                  end
                end
              else
                res = api_call("/project/#{params[:project]}")
                res_json = JSON.parse res
                users = []
                res_json['deploy_envs'].each do |env|
                  env['users'].each do |user|
                    users.push user
                  end
                end
                users.uniq!
                return JSON.pretty_generate users
              end
            end
              
            app.post '/project/:project_id/deploy', &deploy
            app.post '/project', &create
            app.post '/request', &request_project
            app.post '/request/:request_id/apply', &apply_request
            app.get '/requests', &requests
            app.get '/requests/count', &requests_count
            app.put '/project', &update
            app.get '/collections/projects', &get_projects
            app.get '/project_servers/:project_id', &get_project_servers
            app.put '/project/:project/user', &add_user
            app.delete '/project/:project/user', &delete_user
            app.get '/project/:project/users/?:deploy_env?', &env_users
            
          end
      
        end
      end
    end
  end
end
