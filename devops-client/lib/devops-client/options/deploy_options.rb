require "devops-client/options/common_options"

class DeployOptions < CommonOptions

  attr_accessor :deploy_params

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.deploy")
   # self.deploy_params = ["PROJECT_ID", "DEPLOY_ENV"]
  end

  def deploy_options
    options do |opts, options|
      opts.banner << self.banner

      options[:tag] = nil
      opts.on("--tag TAG1,TAG2...", "Tag names, comma separated list") do |tags|
        options[:tags] = tags.split(",")
      end
    end
  end

  def banners
    [ self.banner ]
  end

  def banner
    "\tdeploy NODE_NAME [NODE_NAME ...]\n"
  end

  def invalid_deploy_command
    puts "#{self.header}:\n#{self.banner}"
  end

end
