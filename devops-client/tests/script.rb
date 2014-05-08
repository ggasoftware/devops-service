require "./base_test"

class Script < BaseTest
  TITLE = "Script tests - "

  def run
    self.title = TITLE
    run_tests [
      "script list"
    ]

    script = "test_script"
    self.title = TITLE + "add"
    run_tests [
      "script add #{script} script_file.sh"
    ]
    self.title = TITLE + "add, invalid"
    run_tests_invalid [
      "script add #{script} script_file.sh"
    ]
    self.title = TITLE + "check"
    run_test_with_block "script list --format json" do |s|
      JSON.parse(s).include?(script)
    end

    self.title = TITLE + "delete"
    run_tests [
      "script delete #{script} -y"
    ]
    self.title = TITLE + "delete, invalid"
    run_tests_invalid [
      "script delete #{script} -y"
    ]

    self.title = TITLE + "invalid"
    run_tests_invalid [
      "script",
      "script create",
      "script create #{script}",
      "script delete",
      "script run",
      "script run #{script}"
    ]
  end

end

