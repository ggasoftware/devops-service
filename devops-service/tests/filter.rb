require "devops_test"
require "list_command"
require "cud_command"
class Filter < DevopsTest
  include ListCommand
  include CudCommand

  def title
    "Filter test"
  end

  def run
    list_providers("filter/:provider/images")

    filters = [
      "foo"
    ]
    cmd = "filter/openstack/image"
    test_auth cmd, {}, 400, "put"
    test_headers cmd, "put"
    test_request cmd, filters, "put", Array

    test_auth cmd, {}, 400, "delete"
    test_headers cmd, "delete"
    test_request cmd, filters, "delete", Array
  end
end
