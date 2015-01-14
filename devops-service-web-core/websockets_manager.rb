#!/usr/bin/env ruby

require 'yaml'
require 'eventmachine'
require 'em-websocket'
require 'json'

$config = YAML.load_file(File.join(File.dirname(__FILE__), 'config/grabber_config.yml'))
$web_sockets = {}

module Broadcaster
  def receive_data(raw_data)
    data = JSON.parse(raw_data)
    puts data

    send_to_sockets(data)

    # send smth as response to close worker's connection
    send_data('please die, tired worker')
  end

  def send_to_sockets(data)
    user_sockets = $web_sockets.select do |ws, handshake|
      handshake.query['username'] == data['username'].to_s
    end

    user_sockets.each do |ws, handshake|
      sending_data = {
        message: data['message'],
        extra: data['extra']
      }
      ws.send(JSON.generate(sending_data))
    end
  end
end


EM.run {
  puts "listen to workers on #{$config['grabber_port']}"
  puts "manage websockets on #{$config['sockets_port']}"

  # listen to workers (proxy their responses to sockets)
  EM.start_server $config['grabber_host'], $config['grabber_port'], Broadcaster

  # manage websockets
  EM::WebSocket.run(host: $config['grabber_host'], port: $config['sockets_port']) do |ws|
    ws.onopen { |handshake|
      ws.send(JSON.generate(message: "Connection succesfully established", extra: {}))
      if handshake.query['username'].nil? || handshake.query['username'].empty?
        ws.close_websocket
      else
        $web_sockets[ws] = handshake
      end
    }

    ws.onclose { $web_sockets.delete(ws)}
  end
}

