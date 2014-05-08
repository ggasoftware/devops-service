require "./base_test"

class Key < BaseTest
  TITLE = "Key tests - "

  def run
    self.title = TITLE
    run_tests [
      "key list"
    ]

    key = "test_key"
    self.title = TITLE + "add"
    run_tests [
      "key add #{key} key_file"
    ]
    self.title = TITLE + "add, invalid"
    run_tests_invalid [
      "key add #{key} key_file"
    ]
    self.title = TITLE + "check"
    run_test_with_block "key list --format json" do |k|
      !JSON.parse(k).detect{|jk| jk["id"] == key and jk["scope"] == "user"}.nil?
    end

    self.title = TITLE + "delete"
    run_tests [
      "key delete #{key} -y"
    ]
    self.title = TITLE + "delete, invalid"
    run_tests_invalid [
      "key delete #{key} -y"
    ]
    self.title = TITLE + "invalid"
    run_tests_invalid [
      "key",
      "key add",
      "key add #{key}",
      "key delete"
    ]
  end

end

