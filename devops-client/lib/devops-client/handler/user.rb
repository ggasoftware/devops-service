require "devops-client/handler/handler"
require "devops-client/options/user_options"
require "devops-client/output/user"

class User < Handler
  include Output::User

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = UserOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler
      output
    when "create"
      self.options = @options_parser.create_options
      create_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    when "grant"
      self.options = @options_parser.grant_options
      grant_handler @options_parser.args
    when "password"
      self.options = @options_parser.password_options
      password_handler @options_parser.args
    when "email"
      self.options = @options_parser.email_options
      email_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def list_handler
    @list = get("/users")
  end

  def create_handler args
    r = inspect_parameters @options_parser.create_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_create_command
      abort(r)
    end

    password = self.options[:new_password] || enter_password(args[2])

    q = {
      "username" => args[2],
      "password" => password,
      "email" => args[3]
    }
    post "/user", q
  end

  def delete_handler args
    r = inspect_parameters @options_parser.delete_params, args[2]
    unless r.nil?
      @options_parser.invalid_delete_command
      abort(r)
    end

    if question(I18n.t("handler.user.question.delete", :name => args[2]))
      delete "/user/#{args[2]}"
    end
  end

  def password_handler args
    r = inspect_parameters @options_parser.password_params, args[2]
    unless r.nil?
      @options_parser.invalid_password_command
      abort(r)
    end

    password = enter_password(args[2])
    q = {
        "password" => password
    }

    put "/user/#{args[2]}/password", q
  end

  def email_handler args
    r = inspect_parameters @options_parser.email_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_email_command
      abort(r)
    end
    q = {
        "email" => args[3]
    }
    put "/user/#{args[2]}/email", q
  end

  def grant_handler args
    r = inspect_parameters @options_parser.grant_params, args[2], args[3], args[4]
    unless r.nil?
      @options_parser.invalid_grant_command
      abort(r)
    end

    args[3] = '' if args[3].nil?
    q = {
      'cmd' => args[3],
      'privileges' => args[4]
    }

    put "/user/#{args[2]}", q
  end

  def enter_password user
    print "Enter password for '#{user}': "
    password = ""
    begin
      system("stty -echo")
      password = STDIN.gets.strip
      puts
    ensure
      system("stty echo")
    end
    password
  end

end
