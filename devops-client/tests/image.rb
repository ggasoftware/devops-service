require "./base_test"
class Image < BaseTest
  TITLE = "Image tests"

  def run
    self.title = TITLE
    image_o = {
      :provider => "openstack",
      :id => "89ecfe3f-9f25-4982-a0cf-b9b3814c02d6"
    }
    run_tests [ "image list",
                "image list ec2",
                "image list openstack",
                "image list provider ec2",
                "image list provider openstack"
    #            "image create --image RHEL-6.4_GA-x86_64-7-Hourly2 --ssh_user root --no_bootstrap_template -y --provider ec2",
    #            "image create --image ubuntu-12.04-qcow-amd64 --ssh_user root --no_bootstrap_template -y --provider openstack",
    #            "image show cirros",
    #            "image update cirros ./image_update_test_file",
    #            "image delete cirros"
    ]
  end
end

# test/test
