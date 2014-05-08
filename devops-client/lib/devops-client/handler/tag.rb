require "devops-client/handler/handler"
require "devops-client/options/tag_options"
require "json"
require "devops-client/output/tag"

class Tag < Handler
  include Output::Tag

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = TagOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler @options_parser.args
      output
    when "create"
      self.options = @options_parser.create_options
      create_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
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
    @list = get("/tags/#{args[2]}")
  end

  def create_handler args
    if args.length == 3
      @options_parser.invalid_create_command
      abort()
    end
    node = args[2]
    tags = args[3..-1]

    post "/tags/#{node}", tags
  end

  def delete_handler args
    if args.length == 3
      @options_parser.invalid_delete_command
      abort()
    end
    node = args[2]
    tags = args[3..-1]

    if question(I18n.t("handler.user.question.delete", :name => tags.join("', '"), :node => node))
      delete "/tags/#{node}", tags
    end
  end
end
