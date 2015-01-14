require "json"
require "routes/v2.0/base_routes"
require "sidekiq"

module Version2_0
  class StatusRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Status routes initialized"
    end

    get "/status/:id" do
      r = Sidekiq.redis do |connection|
        connection.hget("devops", params[:id])
      end
      return [404, "Job with id '#{params[:id]}' not found"] if r.nil?
      r
    end
  end
end
