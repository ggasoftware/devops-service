# To run devops you can use command
# `bundle exec thin -R $devops_home/config.ru -e $env -d -p $port -t 600 -u $user --pid $pid_file --log $log_file start`
require 'rubygems'
require 'bundler/setup'
require "sidekiq/web"

root = File.dirname(__FILE__)
require File.join(root, "devops-service")
require File.join(root, "client")
require File.join(root, "report")
require File.join(root, "version")

# Read configuration file
config_file = File.join(root, "config.rb")
config = {}
if File.exists? config_file
  eval File.read config_file
else
  raise "No config file '#{config_file}' found"
end

config[:devops_dir] = File.join(ENV["HOME"], ".devops") if config[:devops_dir].nil?
puts "Devops home: #{config[:devops_dir]}"
unless File.exists?(config[:devops_dir])
  FileUtils.mkdir_p config[:devops_dir]
  puts "Directory '#{config[:devops_dir]}' has been created"
end

config[:report_dir_v2] = File.expand_path(File.join(config[:devops_dir], "report", "v2")) unless config[:report_dir_v2]
[
  :report_dir_v2
].each {|key| d = config[key]; FileUtils.mkdir_p(d) unless File.exists?(d) }
# URL map for API v2.0
run Rack::URLMap.new({
  "#{config[:url_prefix]}/v2.0" => DevopsService.new(config),
  "#{config[:url_prefix]}/client" => Client.new(config),
  "#{config[:url_prefix]}/v2.0/report" => ReportRoutes.new(config, "v2"),
  "#{config[:url_prefix]}/sidekiq" => Sidekiq::Web,
  "#{config[:url_prefix]}/version" => DevopsVersion.new
})
