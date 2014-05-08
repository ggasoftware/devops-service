require "devops_test"
require "list_command"
require "cud_command"
class Tag < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Tag test"
  end

  def run
    self.username = USERNAME
    self.get("tags")
    self.check_status 404
    list("tags/foo", nil, 404)

    self.username = USERNAME

    tags = {
      :tags => ["tag1"]
    }

    test_headers "tags/foo"
    test_request "tags/foo", tags
    test_auth "tags/foo", tags

    test_headers "tags/foo", "delete"
    test_request "tags/foo", tags, "delete", Hash
    test_auth "tags/foo", tags, 400, "delete"
  end
end
