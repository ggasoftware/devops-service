require "db/exceptions/invalid_record"
require "commands/image"

module DeployEnvCommands

  include ImageCommands

  # All these commands should be removed when all deploy envs are switched to new validation system

  def check_expires! val
    raise InvalidRecord.new "Parameter 'expires' is invalid" if val.match(/^[0-9]+[smhdw]$/).nil?
  end

  def check_flavor! p, val
    f = p.flavors.detect{|f| f["id"] == val}
    raise InvalidRecord.new "Invalid flavor '#{val}'" if f.nil?
  end

  def check_image! p, val
    images = get_images(DevopsService.mongo, p.name)
    raise InvalidRecord.new "Invalid image '#{val}'" unless images.map{|i| i["id"]}.include?(val)
  end

  def check_subnets_and_groups! p, subnets, groups
    networks = p.networks
    n = subnets - networks.map{|n| n["name"]}
    raise InvalidRecord.new "Invalid networks '#{n.join("', '")}'" unless n.empty?

    filter = yield(networks)
=begin
    if p.name == ::Provider::Ec2::PROVIDER
      unless subnets.empty?
        subnets = [ subnets[0] ] if subnets.size > 1
        filter = {"vpc-id" => networks.detect{|n| n["name"] == subnets[0]}["vpcId"] }
      end
    elsif p.name == ::Provider::Openstack::PROVIDER
      if subnets.empty?
        raise InvalidRecord.new "Subnets array can not be empty"
      end
    end
=end

    g = groups - p.groups(filter).keys
    raise InvalidRecord.new "Invalid groups '#{g.join("', '")}'" unless g.empty?
  end

  def check_users! val
    users = DevopsService.mongo.users_names(val)
    buf = val - users
    raise InvalidRecord.new("Invalid users: '#{buf.join("', '")}'") unless buf.empty?
  end

end
