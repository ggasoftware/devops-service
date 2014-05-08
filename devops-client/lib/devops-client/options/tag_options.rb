require "devops-client/options/common_options"

class TagOptions < CommonOptions
  commands :create, :delete, :list

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.tag")
    self.banner_header = "tag"
    self.create_params = ["NODE_NAME", "TAG_NAME", "[TAG_NAME ...]"]
    self.delete_params = ["NODE_NAME", "TAG_NAME", "[TAG_NAME ...]"]
    self.list_params = ["NODE_NAME"]
  end
end
