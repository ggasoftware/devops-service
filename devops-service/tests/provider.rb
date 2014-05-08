require "devops_test"
require "list_command"
class Provider < DevopsTest

  include ListCommand

  def title
    "Provider test"
  end

  def run
    list("providers")
  end
end
