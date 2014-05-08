require "devops-client/handler/provider"
require "devops-client/handler/handler"
require "devops-client/options/image_options"
require "devops-client/output/image"
require "devops-client/handler/bootstrap_templates"

class Image < Handler

  include Output::Image

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = ImageOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler @options_parser.args
      output
    when "show"
      self.options = @options_parser.show_options
      show_handler @options_parser.args
      output
    when "create"
      self.options = @options_parser.create_options
      create_handler
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    when "update"
      self.options = @options_parser.update_options
      update_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def get_providers
    p = Provider.new(@host, self.options)
    p.auth = self.auth
    return p.list_handler(["provider", "list"]), p.table
  end

  def get_templates
    bt = BootstrapTemplates.new(@host, self.options)
    bt.auth = self.auth
    return bt.list_handler(["templates", "list"]), bt.table
  end

  def create_handler
    providers, table = get_providers
    provider = (self.options[:provider].nil? ? providers[ choose_number_from_list(I18n.t("headers.provider"), providers, table) ] : self.options[:provider])
    provider_images provider
    q = { "provider" => provider }

    image = nil
    if options[:image_id].nil?
      image = choose_image_cmd(@list, self.table)
    else
      image = @list.detect{|i| i["id"] == options[:image_id]}
      abort("Invalid image id '#{options[:image_id]}'") if image.nil?
    end
    q["name"] = image["name"]
    q["id"] = image["id"]

    if options[:ssh_username].nil?
      q["remote_user"] = enter_parameter(I18n.t("handler.image.create.ssh_user") + ": ")
    else
      q["remote_user"] = options[:ssh_username]
    end

    q["bootstrap_template"] = if options[:bootstrap_template].nil? and options[:no_bootstrap_template] == false
      bt, bt_t = get_templates
      i = choose_number_from_list(I18n.t("handler.image.create.template"), bt, bt_t, -1)
      if i == -1
        nil
      else
        bt[i]
      end
    else
      nil
    end
    json = JSON.pretty_generate(q)
    post_body "/image", json if question(I18n.t("handler.image.question.create")){puts json}
  end

  def list_handler args
    if args[2].nil?
      @provider = false
      @list = get("/images")
    elsif args[2] == "provider" and (args[3] == "ec2" || args[3] == "openstack")
      provider_images args[3]
    elsif args[2] == "ec2" || args[2] == "openstack"
      @provider = false
      @list = get("/images", :provider => args[2])
    else
      @options_parser.invalid_list_command
      abort()
    end
  end

  def provider_images p
    @provider = true
    @list = get("/images/provider/#{p}")
  end

  def show_handler args
    r = inspect_parameters @options_parser.show_params, args[2]
    unless r.nil?
      @options_parser.invalid_show_command
      abort(r)
    end
    @show = get "/image/#{args[2]}"
  end

  def delete_handler args
    r = inspect_parameters @options_parser.delete_params, args[2]
    unless r.nil?
      @options_parser.invalid_delete_command
      abort(r)
    end
    if question(I18n.t("handler.image.question.delete", :name => args[2]))
      delete "/image/#{args[2]}"
    end
  end

  def update_handler args
    r = inspect_parameters @options_parser.update_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_update_command
      abort(r)
    end
    update_object_from_file "image", args[2], args[3]
  end

end
