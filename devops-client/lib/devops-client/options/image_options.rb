require "devops-client/options/common_options"

class ImageOptions < CommonOptions

  commands :create, :delete, :list, :show, :update

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.image")
    self.banner_header = "image"
    self.list_params = ["[provider]", "[ec2|openstack]"]
    self.show_params = ["IMAGE"]
    self.delete_params = ["IMAGE"]
    self.update_params = ["IMAGE", "FILE"]
  end

  def create_options

    self.options do |opts, options|
      opts.banner << self.create_banner

      options[:provider] = nil
      opts.on("--provider PROVIDER", "Image provider") do |provider|
        options[:provider] = provider
      end

      options[:image_id] = nil
      opts.on("--image IMAGE_ID", "Image identifier") do |image_id|
        options[:image_id] = image_id
      end

      options[:ssh_username] = nil
      opts.on("--ssh_user USER", "SSH user name") do |username|
        options[:ssh_username] = username
      end

      options[:bootstrap_template] = nil
      opts.on("--bootstrap_template TEMPLATE", "Bootstrap template") do |template|
        options[:bootstrap_template] = template
      end

      options[:no_bootstrap_template] = false
      opts.on("--no_bootstrap_template", "Do not specify bootstrap template") do
        options[:no_bootstrap_template] = true
      end

    end
  end

end
