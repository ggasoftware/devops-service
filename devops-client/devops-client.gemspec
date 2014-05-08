# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devops-client/version'
require 'devops-client/name'

Gem::Specification.new do |gem|
  #devops-client
  gem.name          = DevopsClient::NAME
  gem.version       = DevopsClient::VERSION
  gem.authors       = ["amartynov"]
  gem.email         = ["amartynov@ggasoftware.com"]
  gem.description   = %q{This is client for devops service}
  gem.summary       = %q{This is client for devops service}
  gem.homepage      = ""

  gem.files         = Dir['{bin,lib,completion,locales}/**/*', 'README*', 'LICENSE*']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
#  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("httpclient", ">= 2.3")
  gem.add_dependency("json")
  gem.add_dependency("terminal-table")
end
