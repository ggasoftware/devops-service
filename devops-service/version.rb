require 'sinatra/base'

class DevopsVersion < Sinatra::Base

  VERSION = "2.0.1"

  get "/" do
    VERSION
  end
end
