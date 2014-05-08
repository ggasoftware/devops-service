require "optparse"
require "devops-client/options/server_options"
require "devops-client/options/image_options"
require "devops-client/options/project_options"
require "devops-client/options/provider_options"
require "devops-client/options/flavor_options"
require "devops-client/options/common_options"
require "devops-client/options/group_options"
require "devops-client/options/deploy_options"
require "devops-client/options/key_options"
require "devops-client/options/user_options"
require "devops-client/options/tag_options"
require "devops-client/options/script_options"
require "devops-client/options/filter_options"
require "devops-client/options/network_options"
require "devops-client/options/bootstrap_templates_options"

class Main < CommonOptions

  def initialize args, def_options
    super(args, def_options)
  end

  def info
    o = nil
    options do |opts, options|
      opts.banner << BootstrapTemplatesOptions.new(ARGV, default_options).error_banner
      opts.banner << DeployOptions.new(ARGV, default_options).error_banner
      opts.banner << FilterOptions.new(ARGV, default_options).error_banner
      opts.banner << FlavorOptions.new(ARGV, default_options).error_banner
      opts.banner << GroupOptions.new(ARGV, default_options).error_banner
      opts.banner << ImageOptions.new(ARGV, default_options).error_banner
      opts.banner << KeyOptions.new(ARGV, default_options).error_banner
      opts.banner << NetworkOptions.new(ARGV, default_options).error_banner
      opts.banner << ProjectOptions.new(ARGV, default_options).error_banner
      opts.banner << ProviderOptions.new(ARGV, default_options).error_banner
      opts.banner << ScriptOptions.new(ARGV, default_options).error_banner
      opts.banner << ServerOptions.new(ARGV, default_options).error_banner
      opts.banner << TagOptions.new(ARGV, default_options).error_banner
      opts.banner << UserOptions.new(ARGV, default_options).error_banner
      o = opts
    end
    puts(o.banner + "\n")
  end

end
