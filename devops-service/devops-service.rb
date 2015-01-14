#!/usr/bin/env ruby

require "rubygems"
require "sinatra/base"
require "sinatra/streaming"
require "fileutils"

$:.push File.dirname(__FILE__)
require "db/exceptions/invalid_record"
require "db/exceptions/record_not_found"
require "db/validators/all"
require "db/mongo/mongo_connector"
require "providers/provider_factory"

require "routes/v2.0"

class DevopsService < Sinatra::Base

  helpers Sinatra::Streaming

  def initialize config
    super()
    @@config = config
    root = File.dirname(__FILE__)
    @@config[:keys_dir] = File.join(root, "../.devops_files/keys")
    if @@config[:scripts_dir].nil?
      #default scripts dir
      @@config[:scripts_dir] = File.join(root, "../.devops_files/scripts")
    end
    [:keys_dir, :scripts_dir].each {|key| d = @@config[key]; FileUtils.mkdir_p(d) unless File.exists?(d) }
    mongo = DevopsService.mongo
    mongo.create_root_user
    ::Provider::ProviderFactory.init(config)
    set_up_providers_keys!(::Provider::ProviderFactory.all, mongo)

  end

  @@mongo
  # Returns mongo connector
  def self.mongo
    @@mongo ||= MongoConnector.new(@@config[:mongo_db], @@config[:mongo_host], @@config[:mongo_port], @@config[:mongo_user], @@config[:mongo_password])
  end

  # Returns config hash
  def self.config
    @@config
  end

  use Rack::Auth::Basic do |username, password|
    begin
      mongo.user_auth(username, password)
      true
    rescue RecordNotFound => e
      false
    end
  end

  use ::Version2_0::V2_0

  private

  def set_up_providers_keys!(providers, mongo)
    providers.each do |provider|
      next if provider.certificate_path.nil?
      begin
        mongo.key provider.ssh_key, Key::SYSTEM
      rescue RecordNotFound => e
        k = Key.new({"id" => provider.ssh_key, "path" => provider.certificate_path, "scope" => Key::SYSTEM})
        mongo.key_insert k
      end
    end
  end

end
