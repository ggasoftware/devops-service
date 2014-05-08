require "devops_test"
require "list_command"
require "cud_command"
class Script < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Script test"
  end

  def run
    list("scripts")

    self.username = USERNAME
#    test_headers "script/run/foo"

    script = {
      :nodes => ["foo"]
    }

#    test_request "script/run/foo", script, "post", Hash

    test_auth "script/run/foo", script, 404
    test_auth "script/command/foo", {}, 404

    self.send_delete "script/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "script/foo", nil, h, 404
  end
end
