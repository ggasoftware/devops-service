require "optparse"
require "devops-client/options/common_options"

class NetworkOptions < CommonOptions

  commands :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.network")
    self.banner_header = "network"
    self.list_params = ["PROVIDER"]
  end

end

