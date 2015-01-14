class DeployProjectWorker < BaseWorker

  private

  def work!
    project_id = @data.delete('project_id')
    send_request("project/#{project_id}/deploy", JSON.pretty_generate(@data))
  end

end