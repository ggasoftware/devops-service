require "./base_test"

class Output < BaseTest
  TITLE = "Output tests"

  def run
    tests = {
      :server => ["list"],
      :flavor => ["list ec2", "list openstack"],
      :network => ["list ec2", "list openstack"],
      :group => ["list ec2", "list openstack"],
      :templates => ["list"],
      :provider => ["list"],
      :filter => ["image list ec2", "image list openstack"],
      :image => ["list", "list provider", "list provider ec2", "list provider openstack"],
      :key => ["list"],
      :project => ["list"],
      :script => ["list"],
      :server => ["list"],
      :tag => ["list"],
      :user => ["list"]
    }
    ["table", "json", "csv"].each do |f|
      self.title = TITLE + ", format '#{f}'"
      c = []
      tests.each do |k,v|
        v.each do |cmd|
          c.push "#{k} #{cmd}"
        end
      end
      run_tests c, false
    end
  end

end
