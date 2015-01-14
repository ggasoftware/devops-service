require "devops-client/handler/image"
require "devops-client/handler/flavor"
require "devops-client/handler/network"
require "devops-client/handler/group"
require "devops-client/handler/user"
require "devops-client/handler/input_utils"

class DeployEnv

  include InputUtils

  attr_accessor :options, :auth, :flavors, :flavors_table, :images, :images_table, :networks, :networks_table, :groups, :groups_table, :users, :users_table

  def set_parameter obj, key
    if self.options[key].nil?
      obj[key] = yield
    else
      obj[key] = self.options[key]
    end
  end

  def fill obj
    yield(obj) if block_given?

    set_users(obj)

    unless self.options[:run_list].nil?
      self.options[:run_list] = self.options[:run_list].split(",").map{|e| e.strip}
      abort("Invalid run list: '#{self.options[:run_list].join(",")}'") unless DeployEnv.validate_run_list(self.options[:run_list])
    end
    set_parameter obj, :run_list do
      set_run_list_cmd
    end

    unless self.options[:no_expires]
      set_parameter obj, :expires do
        s = enter_parameter_or_empty(I18n.t("options.project.create.expires") + ": ").strip
        s.empty? ? nil : s
      end
    end
  end

  def set_run_list_cmd
    res = nil
    begin
      res = get_comma_separated_list(I18n.t("options.project.create.run_list") + ": ")
    end until DeployEnv.validate_run_list(res)
    res
  end

  # flavors commands
  def set_flavor d
    if self.flavors.nil?
      get_flavors
    end
    unless self.options[:flavor].nil?
      f = self.flavors.detect { |f| f["id"] == self.options[:flavor] }
      abort(I18n.t("handler.project.create.flavor.not_found")) if f.nil?
    end
    set_parameter d, :flavor do
      choose_flavor_cmd(self.flavors, self.flavors_table)["id"]
    end
  end

  def get_flavors
    f = Flavor.new(@host, self.options)
    f.auth = self.auth
    self.flavors = f.list_handler(["flavor", "list", self.provider])
    self.flavors_table = f.table
  end

  # returns flavor hash
  def choose_flavor_cmd flavors, table=nil
    abort(I18n.t("handler.flavor.list.empty")) if flavors.empty?
    flavors[ choose_number_from_list(I18n.t("headers.flavor"), flavors.map{|f| "#{f["id"]}. #{f["name"]} - #{f["ram"]}, #{f["disk"]}, #{f["v_cpus"]} CPU"}.join("\n"), table) ]
  end

  # images commands
  def get_images
    img = Image.new(@host, self.options)
    img.auth = self.auth
    self.images = img.list_handler(["image", "list", self.provider])
    self.images_table = img.table
  end

  def set_image d
    images, ti = nil, nil
    if self.images.nil?
      get_images
    end
    set_parameter d, :image do
      choose_image_cmd(self.images, self.images_table)["id"]
    end
  end

  def get_networks
    n = Network.new(@host, self.options)
    n.auth = self.auth
    self.networks = n.list_handler(["network", "list", self.provider])
    self.networks_table = n.table
  end

  def get_users
    u = User.new(@host, self.options)
    u.auth = self.auth
    self.users = u.list_handler
    self.users_table = u.table
  end

  def set_users d
    if self.users.nil?
      get_users
    end
    set_parameter d, :users do
      list = users.map{|u| u["id"]}
      Set.new choose_indexes_from_list(I18n.t("handler.project.create.user"), list, self.users_table).map{|i| list[i]}
    end
    d[:users].add(self.options[:username])
    d[:users] = d[:users].to_a
  end

  def self.validate_run_list run_list
    return true if run_list.empty?
    rl = /\Arole|recipe\[[\w-]+(::[\w-]+)?\]\Z/
    e = run_list.select {|l| (rl =~ l).nil?}
    res = e.empty?
    puts I18n.t("handler.project.create.run_list.invalid", :list => e.join(", ")) unless res
    res
  end


end
