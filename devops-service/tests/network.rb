require "devops_test"
require "list_command"
class Network < DevopsTest

  include ListCommand

  def title
    "Network test"
  end

  def run
    list_providers("networks/:provider")
  end
end
