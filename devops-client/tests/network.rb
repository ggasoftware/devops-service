require "./base_test"

class Network < BaseTest
  TITLE = "Network tests"

  def run
    self.title = TITLE
    run_tests [
      "network list openstack",
      "network list ec2",
      "network list openstack --format json",
      "network list ec2 --format json"
    ]
    self.title = TITLE + " invalid "
    run_tests_invalid [
      "network list",
      "network"
    ]
  end

end


