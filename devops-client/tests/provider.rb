require "./base_test"

class Provider < BaseTest
  TITLE = "Provider tests"

  def run
    self.title = TITLE
    run_tests [
      "provider list",
      "provider list --format json"
    ]
    self.title = TITLE + " invalid "
    run_tests_invalid [
      "provider"
    ]
  end

end

