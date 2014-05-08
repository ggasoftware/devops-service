require "devops-client/handler/handler"
require "devops-client/options/provider_options"
require "devops-client/output/provider"

class Provider < Handler

  include Output::Provider

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = ProviderOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler @options_parser.args
      output
    else
      @options_parser.invalid_command
    end
  end

  def list_handler args
    r = inspect_parameters @options_parser.list_params
    unless r.nil?
      @options_parser.invalid_list_command
      abort(r)
    end
    @list = get("/providers").sort!{|x,y| x["id"] <=> y["id"]}
  end

end
