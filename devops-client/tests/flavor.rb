require "./base_test"

class Flavor < BaseTest
  TITLE = "Flavor tests"

  def run
    self.title = TITLE
    run_tests [
      "flavor list ec2",
      "flavor list openstack",
      "flavor list ec2 --format json",
      "flavor list openstack --format json"
    ]
    self.title = TITLE + " invalid "
    run_tests_invalid [
      "flavor list",
      "flavor"
    ]
  end

end
