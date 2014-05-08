require "optparse"
require "devops-client/options/common_options"

class FlavorOptions < CommonOptions

  commands :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.flavor")
    self.banner_header = "flavor"
    self.list_params = ["PROVIDER"]
  end

end
