require "devops-client/handler/handler"
require "devops-client/options/deploy_options"

class Deploy < Handler

  def initialize(host, def_options={})
    self.host = host
#    self.def_options = def_options
    @options_parser = DeployOptions.new(ARGV, def_options)
  end

  def handle
    if ARGV.size > 1
      self.options = @options_parser.deploy_options
      deploy_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def deploy_handler args
    tags = options[:tags]
    names = args[1..-1]
    if names.empty?
      @options_parser.invalid_deploy_command
      abort(r)
    end
    post_chunk("/deploy", :names => names, :tags => tags)
  end

end
