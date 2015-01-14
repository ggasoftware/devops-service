require "devops-client/handler/provider"
require "devops-client/handler/image"
require "devops-client/handler/flavor"
require "devops-client/handler/network"
require "devops-client/handler/group"
require "devops-client/handler/user"
require "devops-client/options/project_options"
require "json"
require "set"
require "devops-client/output/project"
require "devops-client/handler/deploy_envs/deploy_env_factory"

class Project < Handler

  attr_accessor :def_options

  include Output::Project

  def initialize(host, def_options)
    self.host = host
    self.def_options = def_options
    @options_parser = ProjectOptions.new(ARGV, def_options)
  end

  def handle
    case ARGV[1]
    when "create"
      self.options = @options_parser.create_options
      create_handler @options_parser.args
    when "delete"
      self.options = @options_parser.delete_options
      delete_handler @options_parser.args
    when "deploy"
      self.options = @options_parser.deploy_options
      deploy_handler @options_parser.args
    when "list"
      self.options = @options_parser.list_options
      list_handler
      output
    when "multi"
      case ARGV[2]
      when "create"
        self.options = @options_parser.multi_create_options
        multi_create_handler @options_parser.args
      else
        @options_parser.invalid_multi_command
        abort(I18n.t("handler.project.invalid_subcommand", :cmd => ARGV[1], :scmd => ARGV[2]))
      end
    when "servers"
      self.options = @options_parser.servers_options
      servers_handler @options_parser.args
      output
    when "set"
      case ARGV[2]
      when "run_list"
        self.options = @options_parser.set_run_list_options
        set_run_list_handler @options_parser.args
      else
        @options_parser.invalid_set_command
        abort(I18n.t("handler.project.invalid_subcommand", :cmd => ARGV[1], :scmd => ARGV[2]))
      end
    when "show"
      self.options = @options_parser.show_options
      show_handler @options_parser.args
      output
    when "update"
      self.options = @options_parser.update_options
      update_handler @options_parser.args
    when "user"
      case ARGV[2]
      when "add"
        self.options = @options_parser.user_add_options
        user_add_handler @options_parser.args
      when "delete"
        self.options = @options_parser.user_delete_options
        user_delete_handler @options_parser.args
      else
        @options_parser.invalid_user_command
        abort(I18n.t("handler.project.invalid_subcommand", :cmd => ARGV[1], :scmd => ARGV[2]))
      end
    when "test"
      self.options = @options_parser.test_options
      test_handler @options_parser.args
      output
    else
      @options_parser.invalid_command
    end
  end

  def list_handler
    @list = get "/projects"
  end

  def delete_handler args
    r = inspect_parameters @options_parser.delete_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_delete_command
      abort(r)
    end
    o = {}
    o[:deploy_env] = args[3] unless args[3].nil?

    message = args[2]
    message += ".#{args[3]}" unless args[3].nil?
    if question(I18n.t("handler.project.question.delete", :name => message))
      delete "/project/#{args[2]}", o
    end
  end

  def show_handler args
    r = inspect_parameters @options_parser.show_params, args[2]
    unless r.nil?
      @options_parser.invalid_show_command
      abort(r)
    end
    @show = get_project_info_obj(args[2])
  end

  def update_handler args
    r = inspect_parameters @options_parser.update_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_update_command
      abort(r)
    end
    update_object_from_file "project", args[2], args[3]
  end

  def create_handler args
    file = self.options[:file]
    unless file.nil?
      json = File.read(file)
      begin
        JSON.parse(json)
      rescue JSON::ParserError => e
        abort(I18n.t("handler.project.create.invalid_json", :file => file))
      end
      post_body("/project", json)
    else
      r = inspect_parameters @options_parser.create_params, args[2]
      unless r.nil?
        @options_parser.invalid_create_command
        abort(r)
      end
      unless self.options[:username].nil? || self.options[:password].nil?
        self.auth[:username] = self.options[:username]
        self.auth[:password] = self.options[:password]
        self.def_options[:username] = self.auth[:username]
      end
      create_project args, :create_project_deploy_env_cmd
    end
  end

  def servers_handler args
    r = inspect_parameters @options_parser.servers_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_servers_command
      abort(r)
    end
    o = {}
    unless args[3].nil?
      o[:deploy_env] = args[3]
    end
    @servers = get "/project/#{args[2]}/servers", o
  end

  def user_add_handler args
    r = inspect_parameters @options_parser.user_add_params, args[3], args[4]
    unless r.nil?
      @options_parser.invalid_user_add_command
      abort(r)
    end
    q = {:users => args[4..-1]}
    q[:deploy_env] = options[:deploy_env] unless options[:deploy_env].nil?
    put "/project/#{args[3]}/user", q
  end

  def user_delete_handler args
    r = inspect_parameters @options_parser.user_delete_params, args[3], args[4]
    unless r.nil?
      @options_parser.invalid_user_delete_command
      abort(r)
    end
    q = {:users => args[4..-1]}
    q[:deploy_env] = options[:deploy_env] unless options[:deploy_env].nil?
    delete_body "/project/#{args[3]}/user", q.to_json
  end

  def multi_create_handler args
    r = inspect_parameters @options_parser.multi_create_params, args[3]
    unless r.nil?
      @options_parser.invalid_multi_create_command
      abort(r)
    end

    create_project args, :create_project_multi_deploy_env_cmd, :multi

    i = Image.new(@host, self.def_options)
    images, ti = i.list_handler, i.table
    f = Flavor.new(@host, self.def_options)
    flavors, tf = f.list_handler, f.table
    g = Group.new(@host, self.def_options)
    groups, tg = g.list_handler, g.table

    list = list_handler
    info, multi = {}, {:type => "multi", :name => args[3], :deploy_envs => []}
    begin # Add environment
      nodes, projects, servers = [], [], {}
      deploy_env = {:identifier => enter_parameter("Deploy environment identifier: ")}
      begin # Add server
        server_name = args[3] + "_" + enter_parameter("Server name: " + args[3] + "_")
        s = servers[server_name] = {}
        s[:groups] = choose_indexes_from_list("Security groups", list, tg, "default", list.index("default")).map{|i| list[i]}
        s[:flavor] = choose_flavor_cmd(flavors, tf)["name"]
        s[:image] = choose_image_cmd(images, ti)["id"]
        subprojects = s[:subprojects] = []

        begin # Add project
          o = {}
          o[:project_id] = project_id = choose_project(list, table)
          info[project_id] = get_project_info_obj(project_id) unless info.has_key?(project_id)
          envs = info[project_id]["deploy_envs"].map{|de| de["identifier"]}
          o[:project_env] = ( envs.size > 1 ? choose_project_env(envs) : envs[0] )
          subprojects.push o
        end while question("Add project?")

      end while question("Add server?")

      deploy_env[:servers] = servers
      multi[:deploy_envs].push deploy_env
    end while question(I18n.t("handler.project.question.add_env"))
    puts JSON.pretty_generate(multi)
    post "/project", :json => multi.to_json if question(I18n.t("handler.project.question.create"))
  end

  def set_run_list_handler args
    r = inspect_parameters @options_parser.set_run_list_params, args[3], args[4], args[5]
    unless r.nil?
      @options_parser.invalid_set_run_list_command
      abort(r)
    end
    run_list = []
    args[5..args.size].each do |e|
      run_list += e.split(",")
    end
    if run_list.empty?
      exit unless question(I18n.t("handler.project.run_list.empty"))
    else
      exit unless DeployEnv.validate_run_list(run_list)
    end
    put "/project/#{args[3]}/#{args[4]}/run_list", run_list
  end

  def deploy_handler args
    r = inspect_parameters @options_parser.deploy_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_deploy_command
      abort(r)
    end
    q = {}
    q[:servers] = options[:servers] unless options[:servers].nil?
    q[:deploy_env] = args[3] unless args[3].nil?
    post_chunk "/project/#{args[2]}/deploy", q
  end

  def test_handler args
    r = inspect_parameters @options_parser.test_params, args[2], args[3]
    unless r.nil?
      @options_parser.invalid_test_command
      abort(r)
    end
    @test = post "/project/test/#{args[2]}/#{args[3]}"
  end

protected
  def get_project_info_obj project_id
    get("/project/#{project_id}")
  end

  def get_providers
    p = Provider.new(@host, self.def_options)
    p.auth = self.auth
    return p.list_handler(["provider", "list"]), p.table
  end

  def create_project args, env_method_name, type=nil
    project_name = args[2]
    providers = {}
    providers[:obj], providers[:table] = get_providers
    begin
      project = get_project_info_obj(project_name)
      puts_warn I18n.t("handler.project.exist", :project => project_name)
      names = project["deploy_envs"].map{|de| de["identifier"]}
      while question(I18n.t("handler.project.question.add_env"))
        d = method(env_method_name).call(project_name, providers, names)
        project["deploy_envs"].push d
        break if self.options[:no_ask]
      end
      puts json = JSON.pretty_generate(project)
      update_object_from_json("project", project_name, json) if question(I18n.t("handler.project.question.update"))
    rescue NotFound => e
      project = create_project_cmd(project_name, providers, env_method_name)
      project[:name] = args[2]
      puts json = JSON.pretty_generate(project)
      post_body("/project", json) if question(I18n.t("handler.project.question.create"))
    end
  end

  def create_project_cmd project_name, providers, env_method
    project = {:deploy_envs => []}
    names = []
    begin
      d = method(env_method).call(project_name, providers, names)
      project[:deploy_envs].push d
      break if self.options[:no_ask]
    end while question(I18n.t("handler.project.question.add_env"))
    project
  end

  def create_project_deploy_env_cmd project, providers, names
    d = {}
    set_identifier(d, names)

    set_provider(d, providers)

    de = DeployEnvFactory.create(d[:provider], @host, self.options, self.auth)
    de.fill d

=begin
    unless d[:provider] == "static"
      set_flavor(d, buf)
      set_image(d, buf)
      vpc_id = set_subnets(d, buf)
      set_groups(d, buf, vpc_id)
    end
    set_users(d, buf)

    unless self.options[:run_list].nil?
      self.options[:run_list] = self.options[:run_list].split(",").map{|e| e.strip}
      abort("Invalid run list: '#{self.options[:run_list].join(",")}'") unless Project.validate_run_list(self.options[:run_list])
    end
    set_parameter d, :run_list do
      set_run_list_cmd project, d[:identifier]
    end

    unless self.options[:no_expires]
      set_parameter d, :expires do
        s = enter_parameter_or_empty(I18n.t("options.project.create.expires") + ": ").strip
        s.empty? ? nil : s
      end
    end
=end
    d
  end

  def create_project_multi_deploy_env_cmd project, providers, names
    d = {}
    set_identifier(d, names)

    set_provider(d, providers)
    buf = providers[d[:provider]]

    set_flavor(d, buf)
    set_image(d, buf)
    vpc_id = set_subnets(d, buf)
    set_groups(d, buf, vpc_id)
    set_users(d, buf)

    unless self.options[:run_list].nil?
      self.options[:run_list] = self.options[:run_list].split(",").map{|e| e.strip}
      abort("Invalid run list: '#{self.options[:run_list].join(",")}'") unless DeployEnv.validate_run_list(self.options[:run_list])
    end
    set_parameter d, :run_list do
      set_run_list_cmd project, d[:identifier]
    end

    unless self.options[:no_expires]
      set_parameter d, :expires do
        s = enter_parameter_or_empty(I18n.t("options.project.create.expires") + ": ").strip
        s.empty? ? nil : s
      end
    end
    d
  end

  def set_identifier d, names
    set_parameter d, :identifier do
      begin
        n = enter_parameter I18n.t("handler.project.create.env") + ": "
        if names.include?(n)
          puts I18n.t("handler.project.create.env_exist", :env => n)
          raise ArgumentError
        else
          names.push n
          n
        end
      rescue ArgumentError
        retry
      end
    end
  end

  def set_provider d, providers
    set_parameter d, :provider do
      providers[:obj][ choose_number_from_list(I18n.t("headers.provider"), providers[:obj], providers[:table]) ]
    end
  end

  def set_parameter obj, key
    if self.options[key].nil?
      obj[key] = yield
    else
      obj[key] = self.options[key]
    end
  end

  # returns project id
  def choose_project projects, table=nil
    abort(I18n.t("handler.project.list.empty")) if projects.empty?
    projects[ choose_number_from_list(I18n.t("headers.project"), projects, table) ]
  end

  # returns project env
  def choose_project_env project_envs, table=nil
    abort(I18n.t("handler.project.env.list.empty")) if project_envs.empty?
    project_envs[ choose_number_from_list(I18n.t("headers.project_env"), project_envs, table) ]
  end

end
