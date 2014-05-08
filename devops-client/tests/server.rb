class Server < BaseTest
  TITLE = "Image tests"

  def run
    self.title = TITLE
    run_tests [
      "server list",
      "server list openstack",
      "server list ec2"
    ]
  end
end
