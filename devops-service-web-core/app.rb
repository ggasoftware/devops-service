ENV['RACK_ENV'] ||= 'development'

require 'bundler'
require 'pp'
require 'yaml'

Bundler.require :default, ENV['RACK_ENV'].to_sym

#require File.join(File.dirname(__FILE__), 'lib/workers/all.rb')

require_relative 'lib/env/app.rb'


require_relative 'lib/env/routes/auth'
require_relative 'lib/env/routes/extra'

require_relative 'lib/core/routes/project'
require_relative 'lib/core/routes/server'
require_relative 'lib/core/routes/script'
require_relative 'lib/core/routes/key'
require_relative 'lib/core/routes/image'
require_relative 'lib/core/routes/extra'
require_relative 'lib/core/routes/report'
require_relative 'lib/core/routes/model'
require_relative 'lib/core/routes/collection'

class DevopsServiceWeb < Sinatra::Base

  #Register env modules
  register Sinatra::DevopsServiceWeb::Env::App
  register Sinatra::DevopsServiceWeb::Env::Routing::Auth
  register Sinatra::DevopsServiceWeb::Env::Routing::Extra

  #Register core modules
  register Sinatra::DevopsServiceWeb::Core::Routing::Project
  register Sinatra::DevopsServiceWeb::Core::Routing::Server
  register Sinatra::DevopsServiceWeb::Core::Routing::Script
  register Sinatra::DevopsServiceWeb::Core::Routing::Key
  register Sinatra::DevopsServiceWeb::Core::Routing::Image
  register Sinatra::DevopsServiceWeb::Core::Routing::Extra
  register Sinatra::DevopsServiceWeb::Core::Routing::Report
  register Sinatra::DevopsServiceWeb::Core::Routing::Model
  register Sinatra::DevopsServiceWeb::Core::Routing::Collection

  use Rack::Session::Cookie, expire_after: 7200 # 120 min
  use Rack::Logger

  set :server, 'thin'

  config_file = File.join(File.dirname(__FILE__), 'config/config.yml')
  CONFIG = YAML.load_file(config_file)
  HOST = CONFIG['host']
  PATH_PREFIX = CONFIG['path_prefix']
  JSON_HEADERS = CONFIG['json_headers']

  def json_headers
    JSON_HEADERS
  end

  def path_prefix
    PATH_PREFIX
  end

  def host_string
    HOST
  end

  helpers do
    def logger
      request.logger
    end
  end

  def host
    "http://#{host_string}#{path_prefix}"
  end

  def config
    CONFIG
  end

  def access_levels
    config["access_levels"]
  end

  def validate(username, password)
    http = HTTPClient.new
    http.set_auth(host, username, password)
    res = http.get(host + '/v2.0/projects', nil, json_headers)
    return res.ok?
  end

  def get_user_access_level username
    access_levels.each do |al|
      finded = al["users"].find { |u| u == username } if al["users"]
      return al["level"] if finded
    end
    return 1
  end

  def get_app_options
    package_file = load_file("package.json")
    package_json = JSON.parse(package_file)
    access_level = get_user_access_level session[:username]
    {
			version: package_json["version"],
			#TODO bring out to config file
			envNames: ["dev", "test", "prod", "release", "ci"],
      config: CONFIG,
      accessLevel: access_level
	  }
  end

  def set_session_username username, email
		session[:username] = username if username
		session[:email] = email if email
  end

  def load_file path
    File.read(path)
  end

  def web_admin_creds
    { username: config["web_admin"]["username"], password: config["web_admin"]["password"] }
  end

  def session_creds
    { username: session[:username], email: session[:email] }
  end

  def api_call(path, query: nil, data: nil, method: :get, creds: session_creds)
		puts session_creds.inspect
    url = "#{host}/v2.0#{path}"
    raise unless [:get, :post, :delete, :put].include?(method)
    request_params = (method == :get) ? query : data
		json_headers["REMOTE_USER"] = session_creds[:username]
		json_headers["EMAIL"] = session_creds[:email]
		puts json_headers.inspect
    submit(creds) do |http|
      http.send(method, url, request_params, json_headers)
    end
  end

  def submit creds
    http = HTTPClient.new
    http.set_auth(host, creds[:username], creds[:password])
    res = yield http
    status res.status
    res.body
  end

  def prepare_deploy_envs_params!
    params['deploy_envs'].each do |env|
      env['expires'] = nil if env['expires'] == ''
      run_list = env['run_list'].map do |s|
        s.strip
      end.delete_if do |s|
        s.strip.empty?
      end

      env['run_list'] = run_list
    end
  end

end
