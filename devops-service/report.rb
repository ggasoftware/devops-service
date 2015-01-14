require 'sinatra/base'

class ReportRoutes < Sinatra::Base

  def initialize config, version
    super()
    @@config = config
  end

  enable :inline_templates

  get "/all" do
    options = {}
    ["project", "deploy_env", "type", "created_by", "date_from", "date_to", "sort", "status"].each do |k|
      options[k] = params[k] unless params[k].nil?
    end
    json DevopsService.mongo.reports(options).map{|r| r.to_hash}
=begin
    res = {}
    uri = URI.parse(request.url)
    pref = File.dirname(uri.path)
    @paths.each do |key, dir|
      files = []
      Dir[File.join(dir, "/**/*")].each do |f|
        next if File.directory?(f)
        jid = File.basename(f)
        uri.path = File.join(pref, key, f[dir.length..-1])
        o = {
          "file" => uri.to_s,
          "created" => File.ctime(f).to_s,
          "status" => task_status(jid)
        }
        files.push o
      end
      res[key] = files
    end
    json res
=end
  end

  get "/:id" do
    r = DevopsService.mongo.report(params[:id])
    file = r.file
    return [404, "Report '#{params[:id]}' does not exist"] unless File.exists? file
    @text = File.read(file)
    @done = completed?(params[:id])
    erb :index
  end

  get "/favicon.ico" do
    [404, ""]
  end

  def completed? id
    r = task_status(id)
    r == "completed" or r == "failed"
  end

  def task_status id
    r = Sidekiq.redis do |connection|
      connection.hget("devops", id)
    end
  end

end

__END__

@@ layout
<html>
  <head>
    <% unless @done %>
    <script>
      function reload() {
        location.reload();
      }
      setTimeout(reload, 5000);
    </script>
    <% end %>
  </head>
  <body>
    <%= yield %>
  </body>
</html>

@@ index
<pre>
<%= @text %>
</pre>
