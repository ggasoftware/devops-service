require "devops-client/handler/handler"
require "devops-client/options/script_options"
require "devops-client/output/script"

class Script < Handler
  include Output::Script

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = ScriptOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler @options_parser.args
      output
    when "add"
      self.options = @options_parser.add_options
      add_handler @options_parser.args
    when "run"
      self.options = @options_parser.run_options
      run_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    when "command"
      self.options = @options_parser.command_options
      command_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def command_handler args
    r = inspect_parameters @options_parser.command_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_command_command
      abort(r)
    end
    post_chunk_body "/script/command/#{args[2]}", args[3], false
  end

  def list_handler args
    @list = get("/scripts")
  end

  def add_handler args
    r = inspect_parameters @options_parser.add_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_add_command
      abort(r)
    end
    abort("File '#{args[3]}' does not exist") unless File.exists?(args[3])
    put_body "/script/#{args[2]}", File.read(args[3])
  end

  def delete_handler args
    r = inspect_parameters @options_parser.delete_params, args[2]
    unless r.nil?
      @options_parser.invalid_delete_command
      abort(r)
    end
    if question(I18n.t("handler.script.question.delete", :name => args[2]))
      delete "/script/#{args[2]}"
    end
  end

  def run_handler args
    r = inspect_parameters @options_parser.run_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_run_command
      abort(r)
    end
    q = {
      :nodes => args[3..-1]
    }
    q[:params] = self.options[:params] unless self.options[:params].nil?
    post_chunk "/script/run/#{args[2]}", q
  end

end
