ENV['RACK_ENV'] = 'test'

require_relative File.join('..', 'app')

RSpec.configure do |config|

  config_file = File.join(File.dirname(__FILE__), 'spec_config.yml')
  CFG = YAML.load_file(config_file)

  include Rack::Test::Methods
  config.filter_run_excluding broken: CFG["exclude_broken"]

  def app
    DevopsServiceWeb
  end

  def cfg
    CFG
  end

  def make_auth
      post '/login', { "username" => CFG["username"], "password" => CFG["password"] }
  end

  def array_of_strings? body
    parsed_json = JSON.parse body
    expect(parsed_json.class).to eq Array
    expect(parsed_json.first.class).to eq String
  end

  def array_of_objects? body
    parsed_json = JSON.parse body
    expect(parsed_json.class).to eq Array
    expect(parsed_json.first.class).to eq Hash
  end

  def object? body
    parsed_json = JSON.parse body
    expect(parsed_json.class).to eq Hash
  end

end
