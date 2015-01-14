class DeployServerWorker < BaseWorker

  private

  def work!
    send_request('deploy', JSON.pretty_generate(@data))
  end

end