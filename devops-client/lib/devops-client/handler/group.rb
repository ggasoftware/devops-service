require "devops-client/handler/handler"
require "devops-client/options/group_options"
require "json"
require "devops-client/output/groups"

class Group < Handler

  include Output::Groups

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = GroupOptions.new(ARGV, def_options)
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
    r = inspect_parameters @options_parser.list_params, args[2]
    unless r.nil?
      @options_parser.invalid_list_command
      abort(r)
    end
    @provider = args[2]
    p = {}
    p["vpc-id"] = args[3] unless args[3].nil?
    @list = get("/groups/#{args[2]}", p)
  end

end
