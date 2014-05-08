# To run devops you can use command
# `bundle exec thin -R $devops_home/config.ru -e $env -d -p $port -t 600 -u $user --pid $pid_file --log $log_file start`
require 'rubygems'
require 'bundler/setup'

root = File.dirname(__FILE__)
require File.join(root, "devops-service")
require File.join(root, "client")

# Read configuration file
config_file = File.join(root, "config.rb")
config = {}
if File.exists? config_file
  eval File.read config_file
else
  raise "No config file '#{config_file}' found"
end

# URL map for API v2.0
run Rack::URLMap.new({
  "/v2.0" => DevopsService.new(config),
  "/client" => Client.new(config)
})
