require "devops-client/options/common_options"

class BootstrapTemplatesOptions < CommonOptions

  commands :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.template")
    self.banner_header = "templates"
  end

end
