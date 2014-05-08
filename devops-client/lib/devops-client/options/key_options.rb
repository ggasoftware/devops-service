require "devops-client/options/common_options"

class KeyOptions < CommonOptions
  commands :add, :delete, :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.key")
    self.banner_header = "key"
    self.add_params = ["KEY_NAME", "FILE"]
    self.delete_params = ["KEY_NAME"]
  end

end
