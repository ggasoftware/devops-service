require "providers/base_provider"

module Provider
  # Provider for Amazon EC2
  class Ec2 < BaseProvider

    PROVIDER = "ec2"

    attr_accessor :availability_zone

    def initialize config
      self.certificate_path = config[:aws_certificate]
      self.ssh_key = config[:aws_ssh_key]
      self.connection_options = {
        :provider => "aws",
        :aws_access_key_id => config[:aws_access_key_id],
        :aws_secret_access_key => config[:aws_secret_access_key]
      }
      self.availability_zone = config[:aws_availability_zone] || "us-east-1a"
      self.run_list = config[:aws_integration_run_list] || []
    end

    def configured?
      o = self.connection_options
      super and !(empty_param?(o[:aws_access_key_id]) or empty_param?(o[:aws_secret_access_key]))
    end

    def name
      PROVIDER
    end

    def flavors
      self.compute.flavors.all.map do |f|
        {
          "id" => f.id,
          "cores" => f.cores,
          "disk" => f.disk,
          "name" => f.name,
          "ram" => f.ram
        }
      end
    end

    def groups filters=nil
      buf = {}
      buf = filters.select{|k,v| ["vpc-id"].include?(k)} unless filters.nil?
      g = if buf.empty?
        self.compute.describe_security_groups
      else
        self.compute.describe_security_groups(buf)
      end
      convert_groups(g.body["securityGroupInfo"])
    end

    def images filters
      self.compute.describe_images({"image-id" => filters}).body["imagesSet"].map do |i|
        {
          "id" => i["imageId"],
          "name" => i["name"],
          "status" => i["imageState"]
        }
      end
    end

    def networks_detail
      self.networks
    end

    def networks
      self.compute.describe_subnets.body["subnetSet"].select{|n| n["state"] == "available"}.map do |n|
        {
          "cidr" => n["cidrBlock"],
          "vpcId" => n["vpcId"],
          "subnetId" => n["subnetId"],
          "name" => n["subnetId"],
          "zone" => n["availabilityZone"]
        }
      end
    end

    def servers
      list = self.compute.describe_instances.body["reservationSet"]
      list.select{|l| l["instancesSet"][0]["instanceState"]["name"].to_s != "terminated"}.map do |server|
        convert_server server["instancesSet"][0]
      end
    end

    def server id
      list = self.compute.describe_instances('instance-id' => [id]).body["reservationSet"]
      convert_server list[0]["instancesSet"][0]
    end

    def create_server s, out
      out << "Creating server for project '#{s.project} - #{s.deploy_env}'\n"
      options = {
        "InstanceType" =>  s.options[:flavor],
        "Placement.AvailabilityZone" => s.options[:availability_zone],
        "KeyName" => self.ssh_key
      }
      vpcId = nil
      unless s.options[:subnets].empty?
        options["SubnetId"] = s.options[:subnets][0]
        vpcId = self.networks.detect{|n| n["name"] == options["SubnetId"]}["vpcId"]
        if vpcId.nil?
          out << "Can not get 'vpcId' by subnet name '#{options["SubnetId"]}'\n"
          return false
        end
      end
      options["SecurityGroupId"] = extract_group_ids(s.options[:groups], vpcId).join(",")

      aws_server = nil
      compute = self.compute
      begin
        aws_server = compute.run_instances(s.options[:image], 1, 1, options)
      rescue Excon::Errors::Unauthorized => ue
        #root = XML::Parser.string(ue.response.body).parse.root
        #msg = root.children.find { |node| node.name == "Message" }
        #code = root.children.find { |node| node.name == "Code" }
        code = "TODO"
        msg = ue.response.body
        out << "\nERROR: Unauthorized (#{code}: #{msg})"
        return false
      rescue Fog::Compute::AWS::Error => e
        out << e.message
        return false
      end

      abody = aws_server.body
      instance = abody["instancesSet"][0]
      s.id = instance["instanceId"]

      out << "\nInstance Name: #{s.chef_node_name}"
      out << "\nInstance ID: #{s.id}\n"
      out << "\nWaiting for server..."

      details, state = nil, instance["instanceState"]["name"]
      until state == "running"
        sleep(2)
        details = compute.describe_instances("instance-id" => [s.id]).body["reservationSet"][0]["instancesSet"][0]
        state = details["instanceState"]["name"].to_s
        next if state == "pending" or state == "running"
        out << "Server returns state '#{state}'"
        return false
      end
      s.public_ip = details["ipAddress"]
      s.private_ip = details["privateIpAddress"]
      compute.create_tags(s.id, {"Name" => s.chef_node_name})
      out << "\nDone\n\n"
      out << s.info

      true
    end

    def create_default_chef_node_name s
      "#{self.ssh_key}-#{s.project}-#{s.deploy_env}-#{Time.now.to_i}"
    end

    def delete_server s
      r = self.compute.terminate_instances(s.id)
      i = r.body["instancesSet"][0]
      old_state = i["previousState"]["name"]
      state = i["currentState"]["name"]
      return r.status == 200 ? "Server with id '#{s.id}' changed state '#{old_state}' to '#{state}'" : r.body
    end

    def pause_server s
      es = self.server s.id
      if es["state"] == "running"
        self.compute.stop_instances [ s.id ]
        return nil
      else
        return es["state"]
      end
    end

    def unpause_server s
      es = self.server s.id
      if es["state"] == "stopped"
        self.compute.start_instances [ s.id ]
        return nil
      else
        return es["state"]
      end
    end

    def compute
      connection_compute(connection_options)
    end
  private
    def convert_groups list
      res = {}
      list.each do |g|
        next if g["groupName"].nil?
        res[g["groupName"]] = {
          "description" => g["groupDescription"],
          "id" => g["groupId"]
        }
        rules = []
        g["ipPermissions"].each do |r|
          cidr = r["ipRanges"][0] || {}
          rules.push({
            "protocol" => r["ipProtocol"],
            "from" => r["fromPort"],
            "to" => r["toPort"],
            "cidr" => cidr["cidrIp"]
          })
        end
        res[g["groupName"]]["rules"] = rules
      end
      res
    end

    def convert_server s
      {
        "state" => s["instanceState"]["name"],
        "name" => s["tagSet"]["Name"],
        "image" => s["imageId"],
        "flavor" => s["instanceType"],
        "keypair" => s["keyName"],
        "instance_id" => s["instanceId"],
        "dns_name" => s["dnsName"],
        "zone" => s["placement"]["availabilityZone"],
        "private_ip" => s["privateIpAddress"],
        "public_ip" => s["ipAddress"],
        "launched_at" => s["launchTime"]
      }
    end

    def extract_group_ids names, vpcId
      return [] if names.nil?
      p = nil
      p = {"vpc-id" => vpcId} unless vpcId.nil?
      groups = self.groups(p)
      r = names.map do |name|
        groups[name]["id"]
      end
      r
    end
  end
end
