require "optparse"
require "devops-client/options/common_options"

class GroupOptions < CommonOptions

  commands :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.group")
    self.banner_header = "group"
    self.list_params = ["PROVIDER", "[VPC-ID]"]
  end

end
