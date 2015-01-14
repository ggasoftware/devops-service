require 'sidekiq'
require 'em-http-request'
require 'yaml'
require File.join(File.dirname(__FILE__), '../message_sender.rb')


class BaseWorker
  include Sidekiq::Worker

  def perform(username, password, data)
    data = data.dup
    @username, @password, @data = username, password, data
    @extra = data.delete('extra')
    work!
  end

  private

  def work!
    # should be reimplemented in ancestors
    send_message_to_grabber('I am working')
  end

  def send_request(action, data)
    EM.run do
      http = create_request(action, data)

      http.stream { |chunk|
        send_message_to_grabber(chunk)
      }

      http.callback {
        send_message_to_grabber('_end_', true) # stops EM
      }

      http.errback {
        send_message_to_grabber('error')
      }
    end
  end

  def send_message_to_grabber(message, last = false)
    data = {
      type: self.class.to_s.gsub('Worker', ''),
      extra: @extra,
      username: @username,
      message: message
    }
    MessageSender.new(data, last).send_message
  end

  def create_request(action, data)
    request = EM::HttpRequest.new(build_url(action), connect_timeout: 10, inactivity_timeout: 60)
    headers =  {
      'authorization' => [@username, @password],
      'Accept' => 'application/json',
      'Content-Type' => 'application/json'
    }
    request.post({
      head: headers,
      body: data,
      keepalive: true
    })
  end

  def api_config
    @api_config ||= begin
      config_file = File.join(File.dirname(__FILE__), '../../config/devops_server_config.yml')
      YAML.load_file(config_file)
    end
  end

  def build_url(action)
    "http://#{api_config['host']}/#{api_config['api_version']}/#{action}"
  end

end

