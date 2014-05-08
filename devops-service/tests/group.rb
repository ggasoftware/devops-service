require "devops_test"
require "list_command"
class Group < DevopsTest

  include ListCommand

  def title
    "Group test"
  end

  def run
    list_providers("groups/:provider")
  end
end
