require "devops_test"
require "list_command"
require "cud_command"
class Image < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Image test"
  end

  def run
    list("images")
    PROVIDERS.each do |p|
      list_send("images", 200, :provider => p)
    end
    ["foo", nil, ["ec2"], {"provider" => "ec2"}].each do |p|
      list_send("images", 404, :provider => p)
    end

    cmd = "images/provider/:provider"
    [USERNAME, USERNAME + "_r", ROOTUSER].each do |u|
      self.username = u
      PROVIDERS.each do |p|
        list_send(cmd.gsub(":provider", p), 200)
      end
      list_send(cmd.gsub(":provider", "foo"), 404)
      self.get("images/provider")
      self.check_status 404
    end
    list_deny do
      PROVIDERS.each do |p|
        list_send(cmd.gsub(":provider", p), 401)
      end
      list_send(cmd.gsub(":provider", "foo"), 401)
      self.get("images/provider")
      self.check_status 404
    end

    image = {
      :id => "foo_image",
      :provider => "foo_provider",
      :name => "foo_name",
      :remote_user => "foo_user",
    }
    all_privileges
    test_headers "image"
    test_request "image", image
    self.send_post "image", image, HEADERS, 400
    i = image.clone
    i[:provider] = "openstack"
    self.send_post "image", i, HEADERS, 400

    test_auth "image", image

    test_auth "image/foo", {}, 404, "delete"
    self.send_delete "image/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "image/foo", nil, h, 404
  end

end
