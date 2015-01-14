require "devops-client/handler/deploy_envs/deploy_env"

class DeployEnvEc2 < DeployEnv

  NAME = "ec2"

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
      vpc_id = set_subnets(o)
      set_groups(o, vpc_id)
    end
  end

  def set_subnets d
    if self.networks.nil?
      get_networks
    end
    unless self.options[:subnets].nil?
      self.options[:subnets] = [ self.options[:subnets][0] ]
    end
    vpc_id = nil
    set_parameter d, :subnets do
      if self.networks.any?
        num = choose_number_from_list(I18n.t("handler.project.create.subnet.ec2"), self.networks, self.networks_table, -1)
        vpc_id = self.networks[num]["vpcId"] unless num == -1
        num == -1 ? [] : [ self.networks[num]["subnetId"] ]
      else
        []
      end
    end
    return vpc_id
  end

  def get_groups vpcId
    g = Group.new(@host, self.options)
    g.auth = self.auth
    p = ["group", "list", provider]
    p.push vpcId if !vpcId.nil?
    self.groups = g.list_handler(p)
    self.groups_table = g.table
  end

  def set_groups d, vpc_id
    if self.groups.nil?
      get_groups(vpc_id)
    end
    set_parameter d, :groups do
      list = groups.keys
      choose_indexes_from_list(I18n.t("options.project.create.groups"), list, self.groups_table, "default", list.index("default")).map{|i| list[i]}
    end
  end

end
