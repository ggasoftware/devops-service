class CreateServerWorker < BaseWorker

  private

  def work!
    send_request("server", JSON.pretty_generate(@data))
  end

end