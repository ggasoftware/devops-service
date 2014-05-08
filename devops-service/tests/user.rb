require "devops_test"
require "list_command"
require "cud_command"
class User < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "User test"
  end

  def run
    list("users")

    self.username = USERNAME

    user = {
      :username => "foo",
      :password => "foo",
    }

    test_headers "user"
    test_request "user", user
    test_auth "user", user

    test_auth "user/foo", user, 404, "delete"
    self.send_delete "user/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "user/foo", nil, h, 404

    privileges = {
      :privileges => "foo",
      :cmd => "foo"
    }
    test_auth "user/foo", privileges, 404, "put"
    test_headers "user/foo", "put"
    test_request "user/foo", privileges, "put", Hash

    pass = {
      :password => "foo"
    }
    test_auth "user/foo/password", pass, 400, "put"
    test_headers "user/foo/password", "put"
    test_request "user/foo/password", pass, "put", Hash

  end
end
