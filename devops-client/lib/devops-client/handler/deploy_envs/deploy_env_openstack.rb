require "devops-client/handler/deploy_envs/deploy_env"

class DeployEnvOpenstack < DeployEnv

  NAME = "openstack"

  def initialize host, options, auth
    @host = host
    self.auth = auth
    self.options = options
  end

  def provider
    NAME
  end

  def fill obj
    super(obj) do |o|
      set_flavor(o)
      set_image(o)
      set_subnets(o)
      set_groups(o)
    end
  end

  def set_subnets d
    networks, tn = nil, nil
    if self.networks.nil?
      get_networks
    end
    set_parameter d, :subnets do
      s = []
      begin
        s = choose_indexes_from_list(I18n.t("handler.project.create.subnet.openstack"), self.networks, self.networks_table).map{|i| self.networks[i]["name"]}
      end while s.empty?
      s
    end
  end

  def get_groups
    g = Group.new(@host, self.options)
    g.auth = self.auth
    self.groups = g.list_handler(["group", "list", self.provider])
    self.groups_table = g.table
  end

  def set_groups d
    if self.groups.nil?
      get_groups
    end
    set_parameter d, :groups do
      list = groups.keys
      choose_indexes_from_list(I18n.t("options.project.create.groups"), list, self.groups_table, "default", list.index("default")).map{|i| list[i]}
    end
  end

end
