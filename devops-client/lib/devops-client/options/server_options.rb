require "devops-client/options/common_options"

class ServerOptions < CommonOptions

  commands :add, :bootstrap, :create, :delete, :list, :pause, :show, :unpause # :sync,

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.server")
    self.banner_header = "server"
    self.list_params = ["[chef|ec2|openstack]"]
    self.create_params = ["PROJECT_ID", "DEPLOY_ENV"]
    node_params = ["NODE_NAME"]
    self.delete_params = node_params
    self.show_params = node_params
    self.pause_params = node_params
    self.unpause_params = node_params
    self.bootstrap_params = ["INSTANCE_ID"]
    self.add_params = ["PROJECT_ID", "DEPLOY_ENV", "IP", "SSH_USER", "KEY_ID"]
  end

  def delete_options
    options do |opts, options|
      opts.banner << self.delete_banner
      options[:key] = "node"
      opts.on('--instance', "Delete node by instance id") do
        options[:key] = "instance"
      end

      options[:no_ask] = false
      opts.on("--no_ask", "Don't ask for permission for server deletion") do
        options[:no_ask] = true
      end
    end
  end

  def create_options
    options do |opts, options|
      opts.banner << self.create_banner
      opts.on('--without-bootstrap', "Run server without bootsraping phase") do
        options[:without_bootstrap] = true
      end

=begin
      opts.on('--public-ip', "Associate public IP with server") do
        options[:public_ip] = true
      end
=end

      opts.on("-N", "--name NAME", "Set node name") do |n|
        options[:name] = n
      end

      opts.on("-G", "--groups X,Y,Z", "The security groups for this server") do |g|
        options[:groups] = g.split(",")
      end

      opts.on("-f", "--force", "Cancel rollback operation on error") do |f|
        options[:force] = true
      end

      opts.on("--key KEY", "Use another key for the server") do |k|
        options[:key] = k
      end

    end
  end

  def bootstrap_options
    options do |opts, options|
      opts.banner << self.bootstrap_banner

      opts.on("-N", "--name NAME", "Set chef name") do |n|
        options[:name] = n
      end

      opts.on("--bootstrap_template TEMPLATE", "Bootstrap template") do |template|
        options[:bootstrap_template] = template
      end

      opts.on("--run_list LIST", "Comma separated list like 'role[my_role],recipe[my_recipe]'") do |list|
        options[:run_list] = list.split(",")
      end
    end
  end

  def add_options
    options do |opts, options|
      opts.banner << self.add_banner

      opts.on('--public-ip PUBLIC_IP', "Specify public IP for the server") do |ip|
        options[:public_ip] = ip
      end
    end
  end

  def delete_banner
    self.banner_header + " delete NODE_NAME [NODE_NAME ...]\n"
  end

end
