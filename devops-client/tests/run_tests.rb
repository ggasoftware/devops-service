#!/usr/bin/env ruby

dir = File.dirname(__FILE__)
tests = nil
if ARGV.empty?
  tests = ["flavor", "group", "network", "provider", "user", "key", "script", "image", "server", "project", "create_server"]
else
  tests = ARGV
end

classes = []
tests.each do |f|
  require "#{dir}/#{f}.rb"
  case f
  when "flavor"
    classes.push Flavor.new
  when "group"
    classes.push Group.new
  when "network"
    classes.push Network.new
  when "provider"
    classes.push Provider.new
  when "user"
    classes.push User.new
  when "key"
    classes.push Key.new
  when "script"
    classes.push Script.new
  when "image"
    classes.push Image.new
  when "project"
    classes.push Project.new
  when "server"
    classes.push Server.new
  when "output"
    classes.push Output.new
  when "create_server"
    classes.push CreateServer.new
  end
end

classes.each do |c|
  c.run
end
