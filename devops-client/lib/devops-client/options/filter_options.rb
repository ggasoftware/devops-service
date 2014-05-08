require "optparse"
require "devops-client/options/common_options"

class FilterOptions < CommonOptions

  commands :image => [:add, :delete, :list]

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.filters")
    self.banner_header = "filter"
    p = "PROVIDER"
    self.image_list_params = [p]
    i = "IMAGE [IMAGE ...]"
    self.image_add_params = [p, i]
    self.image_delete_params = [p, i]
  end
end
