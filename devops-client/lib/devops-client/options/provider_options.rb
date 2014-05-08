require "optparse"
require "devops-client/options/common_options"

class ProviderOptions < CommonOptions

  commands :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.provider")
    self.banner_header = "provider"
    self.list_params = []
  end

end
