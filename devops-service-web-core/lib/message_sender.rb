require 'eventmachine'
require 'json'
require 'yaml'

class MessageSender

  def initialize(data, last)
    @data = {
      message: data.dup,
      last: last
    }
  end

  def send_message
    EventMachine::connect config['grabber_host'], config['grabber_port'], MessageSenderEM, @data
  end

  private

  def config
    @config ||= begin
      config_file = File.join(File.dirname(__FILE__), '../config', 'grabber_config.yml')
      YAML.load_file(config_file)
    end
  end

end


# EM connection class

class MessageSenderEM < EM::Connection
  def initialize(data)
    @data = data
  end

  def post_init
    send_data JSON.generate(@data[:message])
  end

  def receive_data(response)
    EM.stop if @data[:last]
  end

end

