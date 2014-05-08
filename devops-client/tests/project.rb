require "./base_test"

class Project < BaseTest
  TITLE = "Project tests"

  def run
  	self.title = TITLE
  	run_tests ["project list"]
  	run_tests ["project create endtest --groups default --deploy_env dev --flavor c1.small --image cirros --run_list role[devops_service_dev] -y"]
  	run_tests ["project show test"]
  	run_tests ["project servers test"]
  	run_tests ["project set run_list test dev role[devops_service_dev]"]
  	run_tests ["project update test project_update_test_file"]
  	run_tests ["project delete test"]
  end
end
