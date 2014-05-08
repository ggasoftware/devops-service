require "./base_test"

class User < BaseTest
  TITLE = "User tests - "

  def run
    user = "test_user"
    psw = "test"
    self.title = TITLE + "list"
    run_tests [
      "user list"
    ]
    self.title = TITLE + "create"
    run_tests [
      "user create #{user} --password #{psw}"
    ]
    self.title = TITLE + "create, invalid"
    run_tests_invalid [
      "user create #{user} --password #{psw}"
    ]

    run_test_with_block "user list --format json" do |o|
      !JSON.parse(o).detect{|u| u["id"] == user}.nil?
    end

    self.title = TITLE + "grant"
    cmds = %w{flavor group image project server key user filter network provider script}
    p = %w{r w rw}
    cmds.each do |c|
      p.each do |pr|
        self.title = TITLE + "grant #{c} #{pr}"
        run_tests ["user grant #{user} #{c} #{pr}"]
        run_test_with_block "user list --format json" do |o|
          u = JSON.parse(o).detect{|u| u["id"] == user}
          u["privileges"][c] == pr
        end
      end
    end
    p.push("")
    p.each do |pr|
      self.title = TITLE + "grant all #{pr}"
      run_tests ["user grant #{user} all #{pr}"]
      run_test_with_block "user list --format json" do |o|
        u = JSON.parse(o).detect{|u| u["id"] == user}
        u["privileges"].each do |cmd, p|
          unless p == pr
            puts_error "#{cmd} should be equals '#{pr}' but it is '#{p}'"
          end
          true
        end
      end
    end

    self.title = TITLE + "delete"
    run_tests [
      "user delete #{user} -y"
    ]
    self.title = TITLE + "delete invalid"
    run_tests_invalid [
      "user delete #{user} -y"
    ]

    self.title = TITLE + "invalid"
    run_tests_invalid [
      "user",
      "user create",
      "user delete",
      "user grant",
      "user password"
    ]
  end

end

