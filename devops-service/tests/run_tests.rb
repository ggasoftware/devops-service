#!/usr/bin/env ruby

dir = File.dirname(__FILE__)
$:.push dir
tests = nil
if ARGV.empty?
  tests = %w{flavor group network provider deploy image key script tag filter project user server}
else
  tests = ARGV
end

classes = []
tests.each do |f|
  require "#{dir}/#{f}.rb"
  case f
  when "flavor"
    classes.push Flavor
  when "group"
    classes.push Group
  when "network"
    classes.push Network
  when "provider"
    classes.push Provider
  when "user"
    classes.push User
  when "key"
    classes.push Key
  when "script"
    classes.push Script
  when "image"
    classes.push Image
  when "project"
    classes.push Project
  when "server"
    classes.push Server
  when "deploy"
    classes.push Deploy
  when "tag"
    classes.push Tag
  when "filter"
    classes.push Filter
  end
end

classes.each do |c|
  c.new.run
end
