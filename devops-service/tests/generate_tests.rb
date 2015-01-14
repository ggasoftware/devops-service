#!/usr/bin/env ruby
#
require "erb"
require "yaml"
require "ostruct"
require "fileutils"
require "./templates/fixtures/fixture_formatter"

class Generator < OpenStruct

  CONFIG = "params.yml"
  TESTS_CONFIG = "features/support/config.yml"

  def initialize
    @config = YAML.load_file(File.new(ENV["CONFIG"] || CONFIG))
    load_fixtures()
    super(:config => @config)
  end

  def configure!
    c = {}
    %w{host port username password path_prefix username_without_privileges password_without_privileges}.each do |key|
      c[key] = @config[key]
    end
    File.open(TESTS_CONFIG, "w") {|f| f.write(c.to_yaml) }
    self
  end

  def generate!(templates)
    templates.each do |input, output|
      if File.exists?(input)
        data = render(File.read(input))
        dir = File.dirname(output)
        FileUtils.mkdir_p(dir) unless File.exists?(dir)
        File.open(output, "w") {|f| f.write(data)}
      else
        puts "WARN: file '#{input}' does not exist"
      end
    end
  end

  def clean!(feature_files)
    feature_files.each do |feature_file|
      if File.exists?(feature_file)
        FileUtils.rm(feature_file)
      else
        puts "WARN: file '#{feature_file}' does not exist"
      end
    end
  end

  private

  def render(template)
    ERB.new(template).result(binding)
  end

  def load_fixtures
    @fixtures = {}
    @fixtures['deploy_env'] = YAML.load_file('templates/fixtures/deploy_env.yml')
    @formatter = FixtureFormatter.new(@fixtures)
  end
end

templates = {

  #list
  "templates/api_v2/00_list/flavor.feature.erb" => "features/api_v2/00_list/flavor.feature",
  "templates/api_v2/00_list/10_user.feature.erb" => "features/api_v2/00_list/10_user.feature",

  #create
  "templates/api_v2/10_create/00_filter.feature.erb" => "features/api_v2/10_create/00_filter.feature",
  "templates/api_v2/10_create/10_image.feature.erb" => "features/api_v2/10_create/10_image.feature",
  "templates/api_v2/10_create/20_project.feature.erb" => "features/api_v2/10_create/20_project.feature",
  "templates/api_v2/10_create/30_script.feature.erb" => "features/api_v2/10_create/30_script.feature",
  "templates/api_v2/10_create/40_deploy_env.feature.erb" => "features/api_v2/10_create/40_deploy_env.feature",
  "templates/api_v2/10_create/00_user.feature.erb" => "features/api_v2/10_create/00_user.feature",

  #update
  "templates/api_v2/20_update/10_image.feature.erb" => "features/api_v2/20_update/10_image.feature",
  "templates/api_v2/20_update/00_user.feature.erb" => "features/api_v2/20_update/00_user.feature",

  #delete
  "templates/api_v2/90_delete/10_script.feature.erb" => "features/api_v2/90_delete/10_script.feature",
  "templates/api_v2/90_delete/20_deploy_env.feature.erb" => "features/api_v2/90_delete/20_deploy_env.feature",
  "templates/api_v2/90_delete/80_project.feature.erb" => "features/api_v2/90_delete/80_project.feature",
  "templates/api_v2/90_delete/90_image.feature.erb" => "features/api_v2/90_delete/90_image.feature",
  "templates/api_v2/90_delete/99_filter.feature.erb" => "features/api_v2/90_delete/99_filter.feature",
  "templates/api_v2/90_delete/90_user.feature.erb" => "features/api_v2/90_delete/90_user.feature"

}

generator = Generator.new.configure!
if ARGV.first != 'clean'
  generator.generate!(templates)
else
  generator.clean!(templates.values)
end


