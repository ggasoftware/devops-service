require "devops-client/options/common_options"
require "set"

class ProjectOptions < CommonOptions

  commands :create, :delete, :deploy, :list, {:multi => [:create]}, :servers, {:set => [:run_list]}, :show, :test, :update, {:user => [:add, :delete]}

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.project")
    self.banner_header = "project"
    id = "PROJECT_ID"
    env = "DEPLOY_ENV"
    self.show_params = [id]
    self.create_params = [id]
    self.delete_params = [id, "[#{env}]"]
    self.deploy_params = [id, "[#{env}]"]
    self.set_run_list_params = [id, env, "[(recipe[mycookbook::myrecipe])|(role[myrole]) ...]"]
    self.servers_params = [id, "[#{env}]"]
    self.multi_create_params = [id]
    self.update_params = [id, "FILE"]
    self.user_add_params = [id, "USER_NAME", "[USER_NAME ...]"]
    self.user_delete_params = [id, "USER_NAME", "[USER_NAME ...]"]
    self.test_params = [id, env]
  end

  def create_options
    self.options do |opts, options|
      opts.banner << self.create_banner
      options[:groups] = nil
      opts.on("--groups GROUP_1,GROUP_2...", I18n.t("options.project.create.groups")) do |groups|
        options[:groups] = groups.split(",")
      end

      options[:identifier] = nil
      opts.on("--deploy_env DEPLOY_ID", I18n.t("options.project.create.deploy_env")) do |identifier|
        options[:identifier] = identifier
      end

      options[:file] = nil
      opts.on("-f", "--file FILE", I18n.t("options.project.create.file")) do |file|
        abort("File '#{file}' does not exist") unless File.exist?(file)
        options[:file] = file
      end

      options[:subnets] = nil
      opts.on("--subnets SUBNET,SUBNET...", I18n.t("options.project.create.subnets")) do |subnet|
        options[:subnets] = subnet.split(",")
      end

      options[:flavor] = nil
      opts.on("--flavor FLAVOR", I18n.t("options.project.create.flavor")) do |flavor|
        options[:flavor] = flavor
      end

      options[:image] = nil
      opts.on("--image IMAGE_ID", I18n.t("options.project.create.image")) do |image|
        options[:image] = image
      end

      options[:run_list] = nil
      opts.on("--run_list RUN_LIST", I18n.t("options.project.create.run_list")) do |run_list|
        options[:run_list] = run_list
      end

      options[:users] = nil
      opts.on("--users USER,USER...", I18n.t("options.project.create.users")) do |users|
        options[:users] = Set.new(users.split(","))
      end

      options[:provider] = nil
      opts.on("--provider PROVIDER", I18n.t("options.project.create.provider")) do |provider|
        options[:provider] = provider
      end

      options[:no_expires] = false
      opts.on("--no_expires", I18n.t("options.project.create.no_expires")) do
        options[:no_expires] = true
      end

      options[:expires] = nil
      opts.on("--expires EXPIRES", I18n.t("options.project.create.expires")) do |e|
        options[:expires] = e
      end
    end

  end

  def user_add_options
    self.options do |opts, options|
      opts.banner << self.user_add_banner
      options[:deploy_env] = nil
      opts.on("--deploy_env ENV", I18n.t("options.project.user_add.deploy_env")) do |env|
        options[:deploy_env] = env
      end
    end
  end

  def user_delete_options
    self.options do |opts, options|
      opts.banner << self.user_delete_banner
      options[:deploy_env] = nil
      opts.on("--deploy_env ENV", I18n.t("options.project.user_delete.deploy_env")) do |env|
        options[:deploy_env] = env
      end
    end
  end

  def deploy_options
    options do |opts, options|
      opts.banner << self.deploy_banner
      options[:servers] = nil
      opts.on("--servers SERVERS", I18n.t("options.project.deploy.servers")) do |l|
        options[:servers] = l.split(",")
      end
    end
  end

end
