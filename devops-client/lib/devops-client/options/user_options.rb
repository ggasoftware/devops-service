require "devops-client/options/common_options"

class UserOptions < CommonOptions
  commands :create, :delete, :grant, :list, :password, :email

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.user")
    self.banner_header = "user"
    self.create_params = ["USER_NAME", "EMAIL"]
    self.delete_params = ["USER_NAME"]
    self.password_params = ["USER_NAME"]
    self.email_params = ["USER_NAME", "EMAIL"]
    self.grant_params = ["USER_NAME", "[COMMAND]", "[PRIVILEGES]"]
  end

  def create_options
    self.options do |opts, options|
      opts.banner << self.create_banner

      options[:new_password] = nil
      opts.on("--password PASSWORD", "New user password") do |p|
        options[:new_password] = p
      end

    end
  end

end
