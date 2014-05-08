require "devops_test"
require "list_command"
require "cud_command"
class Key < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Key test"
  end

  def run
    list("keys")

    all_privileges
    key = {
      :content => "content",
      :file_name => "key_file.pem",
      :key_name => "test_key"
    }

    test_headers "key"
    test_auth "key", key
    test_request "key", key
    k = key.clone
    k[:file_name] = "key*_file.pem"
    self.send_post "key", k, HEADERS, 400

    test_auth "key/foo", key, 404, "delete"

    self.send_delete "key/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "key/foo", nil, h, 404
  end
end

