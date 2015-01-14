module Sinatra
  module DevopsServiceWeb
    module Core
      module Routing
        module Report
          
          def self.registered(app)

            reports = lambda do
              date = Date.parse(params[:date])
              dateNext = date + 1
              query_string = "date_from=#{date}&date_to=#{dateNext}"
							api_call("/report/all?#{query_string}")
            end

            app.get '/api/reports/:date', &reports

          end
      
        end
      end
    end
  end
end
