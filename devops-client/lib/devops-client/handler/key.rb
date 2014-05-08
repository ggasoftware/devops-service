require "devops-client/handler/handler"
require "devops-client/options/key_options"
require "json"
require "devops-client/output/key"

class Key < Handler
  include Output::Key

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = KeyOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler
      output
    when "add"
      self.options = @options_parser.add_options
      add_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def add_handler args
    r = inspect_parameters @options_parser.add_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_add_command
      abort(r)
    end

    content = File.read(args[3])
    q = {
      "key_name" => args[2],
      "file_name" => File.basename(args[3]),
      "content" => content
    }
    post "/key", q
  end

  def delete_handler args
    r = inspect_parameters @options_parser.delete_params, args[2]
    unless r.nil?
      @options_parser.invalid_delete_command
      abort(r)
    end
    if question(I18n.t("handler.key.question.delete", :name => args[2]))
      delete "/key/#{args[2]}"
    end
  end

  def list_handler
    @list = get("/keys")
  end

end
