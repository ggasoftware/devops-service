require "devops-client/handler/handler"
require "devops-client/options/server_options"
require "devops-client/output/server"
require "devops-client/handler/project"

class Server < Handler

  include Output::Server

  def initialize(host, def_options={})
    self.host = host
    self.options = def_options
    @options_parser = ServerOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "list"
      self.options = @options_parser.list_options
      list_handler @options_parser.args
      output
    when "bootstrap"
      self.options = @options_parser.bootstrap_options
      bootstrap_handler @options_parser.args
    when "create"
      self.options = @options_parser.create_options
      create_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    when "show"
      self.options = @options_parser.show_options
      show_handler @options_parser.args
      output
    when "sync"
      self.options = @options_parser.sync_options
      sync_handler
    when "pause"
      self.options = @options_parser.pause_options
      pause_handler @options_parser.args
    when "unpause"
      self.options = @options_parser.unpause_options
      unpause_handler @options_parser.args
    when "reserve"
      self.options = @options_parser.reserve_options
      reserve_handler @options_parser.args
    when "unreserve"
      self.options = @options_parser.unreserve_options
      unreserve_handler @options_parser.args
    when "add"
      self.options = @options_parser.add_options
      add_static_handler @options_parser.args
    else
      @options_parser.invalid_command
    end
  end

  def list_handler args
    if args[2].nil?
      @list = get("/servers")
      return @list
    end
    self.options[:type] = args[2]
    @list = case args[2]
    when "chef"
      get("/servers/chef").map {|l| {"chef_node_name" => l}}
    when "ec2", "openstack", "static"
      get("/servers/#{args[2]}")
    else
      @options_parser.invalid_list_command
      abort("Invlid argument '#{args[2]}'")
    end
  end

  def create_handler args
    r = inspect_parameters @options_parser.create_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_create_command
      abort(r)
    end

    q = {
      :project => args[2],
      :deploy_env => args[3]
    }

    [:key, :without_bootstrap, :name, :groups, :force].each do |k|
      q[k] = self.options[k] unless self.options[k].nil?
    end

    post_chunk "/server", q
  end

  def delete_handler args
    args[2..-1].each do |name|
      r = inspect_parameters @options_parser.delete_params, name
      unless r.nil?
        @options_parser.invalid_delete_command
        abort(r)
      end
      if question(I18n.t("handler.server.question.delete", :name => name))
        puts "Server '#{name}', deleting..."
        o = delete("/server/#{name}", options)
        ["server", "chef_node", "chef_client", "message"].each do |k|
          puts o[k] unless o[k].nil?
        end
      end
    end
    ""
  end

  def show_handler args
    r = inspect_parameters @options_parser.show_params, args[2]
    unless r.nil?
      @options_parser.invalid_show_command
      abort r
    end
    @show = get("/server/#{args[2]}")
  end

  def bootstrap_handler args
    r = inspect_parameters @options_parser.bootstrap_params, args[2]
    unless r.nil?
      @options_parser.invalid_bootstrap_command
      abort(r)
    end
    q = {
      :instance_id => args[2]
    }
    [:name, :bootstrap_template, :run_list].each do |k|
      q[k] = self.options[k] unless self.options[k].nil?
    end
    if q.has_key?(:run_list)
      abort unless Project.validate_run_list(q[:run_list])
    end
    post_chunk "/server/bootstrap", q
  end

  def add_static_handler args # add <project> <env> <private_ip> <ssh_username> --public-ip <public_ip> -k <keyname>
    r = inspect_parameters @options_parser.add_params, args[2], args[3], args[4], args[5], args[6]
    unless r.nil?
      @options_parser.invalid_add_command
      abort(r)
    end
    q = {
      :project => args[2],
      :deploy_env => args[3],
      :private_ip => args[4],
      :remote_user => args[5],
      :key => args[6]
    }
    q[:public_ip] = self.options[:public_ip] unless self.options[:public_ip].nil?
    post "/server/add", q
  end

  def pause_handler args
    r = inspect_parameters @options_parser.pause_params, args[2]
    unless r.nil?
      @options_parser.invalid_pause_command
      abort(r)
    end
    post "/server/#{args[2]}/pause", options
  end

  def unpause_handler args
    r = inspect_parameters @options_parser.unpause_params, args[2]
    unless r.nil?
      @options_parser.invalid_unpause_command
      abort(r)
    end
    post "/server/#{args[2]}/unpause", options
  end

  def reserve_handler args
    r = inspect_parameters @options_parser.reserve_params, args[2]
    unless r.nil?
      @options_parser.invalid_reserve_command
      abort(r)
    end
    post "/server/#{args[2]}/reserve", options
  end

  def unreserve_handler args
    r = inspect_parameters @options_parser.unreserve_params, args[2]
    unless r.nil?
      @options_parser.invalid_unreserve_command
      abort(r)
    end
    post "/server/#{args[2]}/unreserve", options
  end

end
