ENV["RACK_ENV"] = "test"
#require File.join(File.dirname(__FILE__), '..', '..', 'config.ru')

require "rubygems"
require 'test/unit'
require 'rack/test'
require "json"

  USERNAME = '<username>'
  PASSWORD = '<password>'
  HOST = '<host>'
  PORT = 7070

class MyWorld

  include Rack::Test::Methods
  @@app = nil
  def app
    @@app ||= eval("Rack::Builder.new {( " + File.read(File.dirname(__FILE__) + '/../../config.ru') + "\n )}")
  end
end

class RequestSender
  require "httpclient"
  require "yaml"

  @last_res = nil
  $test_hash = Hash.new

  # config:
  # host=<host>
  # port=<port>
  # username=<user>
  # password=<psw>
  def initialize
    file = ENV["CONFIG"] || "./features/support/config.yml"
    abort("File does not exist: #{File.absolute_path(file)}") unless File.exists?(file)
    @config = config(file)
  end

  def default_headers
    {
      "REMOTE_USER" => @config["username"]
    }
  end

  def host
    "http://#{@config["host"]}:#{@config["port"]}"
  end

  def create_url path
    host + @config["path_prefix"] + path
  end

  def last_response
    @last_res
  end

  def get path, query, headers={}
    submit do |http|
      http.get(create_url(path), query, default_headers.merge(headers))
    end
  end

  def get_without_privileges path, query={}, headers={}
    user_without_privileges do
      get(path, query, headers)
    end
  end

  def post path, query, headers={}
    post_body(path, JSON.pretty_generate(query), headers)
  end

  def post_body path, body, headers={}
    submit do |http|
      http.receive_timeout = 0 #!!! bring out to appropriate server step
      http.post(create_url(path), body, default_headers.merge(headers))
    end
  end

  def post_without_privileges path, query, headers={}
    user_without_privileges do
      post_body(path, query, headers)
    end
  end

  def put path, query, headers={}
    put_body(path, JSON.pretty_generate(query), headers)
  end

  def put_body path, body, headers={}
    submit do |http|
      http.receive_timeout = 0 #!!! bring out to appropriate server step
      http.put(create_url(path), body, default_headers.merge(headers))
    end
  end

  def put_without_privileges path, query="", headers={}
    user_without_privileges do
      put_body(path, query, headers)
    end
  end

  def delete path, query, headers={}
    delete_body(path, JSON.pretty_generate(query), headers)
  end

  def delete_body path, body, headers={}
    submit do |http|
      http.delete(create_url(path), body, default_headers.merge(headers))
    end
  end

  def delete_without_privileges path, query={}, headers={}
    user_without_privileges do
      delete(path, query, headers)
    end
  end

  def submit
    http = HTTPClient.new
    http.set_auth(nil, @config["username"], @config["password"])
    res = yield http
    @last_res = res
  end

  def user_without_privileges
    buf_u = @config["username"]
    buf_p = @config["password"]
    @config["username"] = @config["username_without_privileges"]
    @config["password"] = @config["password_without_privileges"]
    yield
    @config["username"] = buf_u
    @config["password"] = buf_p
  end

  def config path
    YAML.load_file(path)
  end
end

World do
  #MyWorld.new
  RequestSender.new
end
