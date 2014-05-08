require "devops_test"
require "list_command"
require "cud_command"
class Project < DevopsTest

  include ListCommand
  include CudCommand

  def title
    "Project test"
  end

  def run
    list("projects")
    list("project/foo", nil, 404)
    list_send("project/foo/servers", 404)

    project = {
      :deploy_envs => [
        {
          :flavor => "c1.large",
          :identifier => "test",
          :image => "e6f44159-f50a-49a5-bfd5-865d0f68779d",
          :run_list => [
            "role[solr_test]"
          ],
          :subnets => [
            "private"
          ],
          :expires => nil,
          :provider => "openstack",
          :groups => [
            "default"
          ],
          :users => [
            USERNAME
          ]
        }
      ],
      :name => "test"
    }

    test_auth "project", project
    test_headers "project"
    test_request "project", project
    ["openstack", "ec2"].each do |provider|
      project[:deploy_envs][0].keys.each do |k|
        p = project.clone
        d = p[:deploy_envs][0]
        d[:provider] = provider
        if k == :expires
          ["foo", "", [], {}].each do |v|
            d[k] = v
            send_post "project", p, HEADERS, 400
          end
        elsif k == :run_list or k == :groups or k == :users
          ["", {}, nil].each do |v|
            d[k] = v
            send_post "project", p, HEADERS, 400
          end
        elsif k == :subnets and provider == "ec2"
          ["", {}].each do |v|
            d[k] = v
            send_post "project", p, HEADERS, 400
          end
        else
          d.delete(k)
          send_post "project", p, HEADERS, 400
          [nil, "", [], {}].each do |v|
            d[k] = v
            send_post "project", p, HEADERS, 400
          end
        end
      end
    end

    test_auth "project/foo", project, 404, "delete"
    self.send_delete "project/foo", nil, {}, 406
    h = HEADERS.clone
    h.delete("Content-Type")
    self.send_delete "project/foo", nil, h, 415
    self.send_delete "project/foo", nil, HEADERS, 404
    self.send_delete "project/foo", {:deploy_env => ""}, HEADERS, 400

    deploy = {
      :servers => ["foo"],
      :deploy_env => "foo"
    }
    test_headers "project/foo/deploy", "post", false
    deploy.keys.each do |k|
      d = deploy.clone
      ["", [], {}].each do |v|
        d[k] = v
        send_post "project/foo/deploy", p, HEADERS, 400
      end
    end
#    test_auth "project/foo/deploy", deploy, 404
  end

end
