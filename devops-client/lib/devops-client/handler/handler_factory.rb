class HandlerFactory

  def self.create cmd, host, auth, def_options
    klass = case cmd
    when "flavor"
      require "devops-client/handler/flavor"
      Flavor
    when "image"
      require "devops-client/handler/image"
      Image
    when "filter"
      require "devops-client/handler/filter"
      Filter
    when "group"
      require "devops-client/handler/group"
      Group
    when "deploy"
      require "devops-client/handler/deploy"
      Deploy
    when "project"
      require "devops-client/handler/project"
      Project
    when "network"
      require "devops-client/handler/network"
      Network
    when "key"
      require "devops-client/handler/key"
      Key
    when "user"
      require "devops-client/handler/user"
      User
    when "provider"
      require "devops-client/handler/provider"
      Provider
    when "tag"
      require "devops-client/handler/tag"
      Tag
    when "server"
      require "devops-client/handler/server"
      Server
    when "script"
      require "devops-client/handler/script"
      Script
    when "templates"
      require "devops-client/handler/bootstrap_templates"
      BootstrapTemplates
    else
      require "devops-client/options/main"
      Main.new(ARGV, def_options).info
      exit(10)
    end
    service = klass.new(host, def_options)
    service.auth = auth
    service
  end
end
