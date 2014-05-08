require "devops_test"
require "list_command"
class Flavor < DevopsTest

  include ListCommand

  def title
    "Flavor test"
  end

  def run
    list_providers("flavors/:provider")
  end
end
