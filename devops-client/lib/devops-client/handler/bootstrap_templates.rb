require "devops-client/handler/handler"
require "devops-client/options/bootstrap_templates_options"
require "json"
require "devops-client/output/bootstrap_templates"

class BootstrapTemplates < Handler

  include Output::BootstrapTemplates

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = BootstrapTemplatesOptions.new(ARGV, def_options)
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
    @list = get("/templates")
  end

end

