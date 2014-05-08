class Group < BaseTest
  TITLE = "Group tests"

  def run
    self.title = TITLE
    run_tests [
      "group list ec2",
      "group list openstack",
      "group list ec2 --format json",
      "group list openstack --format json"
    ]
    self.title = TITLE + " invalid "
    run_tests_invalid [
      "group list",
      "group"
    ]
  end

end

