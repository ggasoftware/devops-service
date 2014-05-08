require "devops_test"
require "list_command"
require "cud_command"
class Server < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Server test"
  end

  def run
    list("servers")

    cmd = "servers/:provider"
    p = PROVIDERS.clone
    p.push "chef"
    [USERNAME, USERNAME + "_r", ROOTUSER].each do |u|
      self.username = u
      p.each do |p|
        list_send(cmd.gsub(":provider", p), 200)
      end
      list_send(cmd.gsub(":provider", "foo"), 404)
      list_send("server/foo", 404)
    end
    list_deny do
      p.each do |p|
        list_send(cmd.gsub(":provider", p), 401)
      end
      list_send(cmd.gsub(":provider", "foo"), 401)
      list_send("server/foo", 401)
    end

    test_auth "server/foo", {}, 404, "delete"
    self.send_delete "server/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "server/foo", nil, h, 415
    h = HEADERS.clone
    self.send_delete "server/foo", nil, h, 404

    all_privileges
    server = {
      :project => "foo",
      :deploy_env => "foo",
      :name => "foo",
      :without_bootstrap => true,
      :force => true,
      :groups => [],
      :key => "foo"
    }
    test_headers "server", "post", false
    [:project, :deploy_env, :name, :key].each do |k|
      s = server.clone
      ["", nil, [], {}].each do |v|
        next if k == :name and v.nil?
        s[k] = v
        self.send_post "server", s, HEADERS, 400
      end
    end
    [:force, :without_bootstrap].each do |k|
      s = server.clone
      ["", false, [], {}].each do |v|
        s[k] = v
        self.send_post "server", s, HEADERS, 400
      end
    end
    s = server.clone
    ["", true, [], [true], [{:foo => "foo"}], {}].each do |v|
      s[:groups] = v
      self.send_post "server", s, HEADERS, 400
    end

    test_auth "server", server

    ["server/foo/pause", "server/foo/unpause"].each do |cmd|
      test_auth cmd, nil, 404
      test_headers cmd
    end

    bootstrap = {
      :instance_id => "foo",
      :name => "foo",
      :run_list => ["foo"],
      :bootstrap_template => "foo"
    }
    cmd = "server/bootstrap"
    test_auth cmd, bootstrap
    test_headers cmd, "post", false

    b = bootstrap.clone
    ["", [], {}].each do |v|
      b[:instance_id] = v
      self.send_post cmd, b, HEADERS, 400
    end

    [:name, :bootstrap_template].each do |k|
      b = bootstrap.clone
      ["", [], {}].each do |v|
        b[k] = v
        self.send_post cmd, b, HEADERS, 400
      end
    end

    b = bootstrap.clone
    ["", [nil], [{:foo => "foo"}], [true], {}].each do |v|
      b[:run_list] = v
      self.send_post cmd, b, HEADERS, 400
    end

    cmd = "server/add"
    add = {
      :project => "foo",
      :deploy_env => "foo",
      :key => "foo",
      :remote_user => "foo",
      :private_ip => "foo",
      :public_ip => "foo"
    }
    test_auth cmd, add
    test_headers cmd, "post", false

    [:project, :deploy_env, :key, :remote_user, :private_ip, :public_ip].each do |k|
      a = add.clone
      [nil, "", [], {}].each do |v|
        next if k == :public_ip and v.nil?
        a[k] = v
        self.send_post cmd, a, HEADERS, 400
      end
    end

  end
end
