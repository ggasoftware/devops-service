require 'sinatra/base'

class Client < Sinatra::Base

  def initialize config
    super()
    @@config = config
  end

  # Route to download devops client
  get "/devops-client.gem" do
    begin
      send_file @@config[:client_file]
    rescue
      msg = "No file '#{@@config[:client_file]}' found"
      logger.error msg
      return [404, msg]
    end
  end

  # Route to get client documentation
  get "/ru/index.html" do
    file = File.join(@@config[:public_dir], "ru_index.html")
    if File.exist? file
      File.read(file)
    else
      logger.error "File '#{file}' does not exist"
      return [404, "File '/ru/index.html' does not exist"]
    end
  end

end
