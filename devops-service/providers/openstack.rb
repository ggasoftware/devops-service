require "providers/base_provider"

module Provider
  # Provider for 'openstack'
  class Openstack < BaseProvider

    PROVIDER = "openstack"

    def initialize config
      self.certificate_path = config[:openstack_certificate]
      self.ssh_key = config[:openstack_ssh_key]
      self.connection_options = {
        :provider => PROVIDER,
        :openstack_username => config[:openstack_username],
        :openstack_api_key => config[:openstack_api_key],
        :openstack_auth_url => config[:openstack_auth_url],
        :openstack_tenant => config[:openstack_tenant]
      }
      self.run_list = config[:openstack_integration_run_list] || []
    end

    # Returns 'true' if all parameters defined
    def configured?
      o = self.connection_options
      super and !(empty_param?(o[:openstack_username]) or empty_param?(o[:openstack_api_key]) or empty_param?(o[:openstack_auth_url]) or empty_param?(o[:openstack_tenant]))
    end

    def name
      PROVIDER
    end

    def groups filter=nil
      convert_groups(compute.list_security_groups.body["security_groups"])
    end

    def flavors
      self.compute.list_flavors_detail.body["flavors"].map do |f|
        {
          "id" => f["name"],
          "v_cpus" => f["vcpus"],
          "ram" => f["ram"],
          "disk" => f["disk"]
        }
      end
    end

    def images filters
      self.compute.list_images_detail.body["images"].select{|i| filters.include?(i["id"]) and i["status"] == "ACTIVE"}.map do |i|
        {
          "id" => i["id"],
          "name" => i["name"],
          "status" => i["status"]
        }
      end
    end

    def networks_detail
      net = self.network
      subnets = net.list_subnets.body["subnets"].select{|s| net.current_tenant["id"] == s["tenant_id"]}
      net.list_networks.body["networks"].select{|n| n["router:external"] == false and n["status"] == "ACTIVE" and net.current_tenant["id"] == n["tenant_id"]}.map{|n|
        sn = subnets.detect{|s| n["subnets"][0] == s["id"]}
        {
          "cidr" => sn["cidr"],
          "name" => n["name"],
          "id" => n["id"]
        }
      }
    end

    def networks
      net = self.network
      net.list_networks.body["networks"].select{|n| n["router:external"] == false and n["status"] == "ACTIVE" and net.current_tenant["id"] == n["tenant_id"]}.map{|n|
        {
          "name" => n["name"],
          "id" => n["id"]
        }
      }
    end

    def servers
      list = self.compute.list_servers_detail.body["servers"]
      list.map do |s|
        o = {"state" => s["status"], "name" => s["name"], "image" => s["image"]["id"], "flavor" => s["flavor"]["name"], "keypair" => s["key_name"], "instance_id" => s["id"]}
        s["addresses"].each_value do |a|
          a.each do |addr|
            o["private_ip"] = addr["addr"] if addr["OS-EXT-IPS:type"] == "fixed"
          end
        end
        o
      end
    end

    def create_server s, out
      out << "Creating server for project '#{s.project} - #{s.deploy_env}'\n"
      networks = self.networks.select{|n| s.options[:subnets].include?(n["name"])}
      buf = s.options[:subnets] - networks.map{|n| n["name"]}
      unless buf.empty?
        out << "No networks with names '#{buf.join("', '")}' found"
        return false
      end
      s.options[:flavor] = self.compute.list_flavors_detail.body["flavors"].detect{|f| f["name"] == s.options[:flavor]}["id"]
      out << "Creating server with name '#{s.chef_node_name}', image '#{s.options[:image]}', flavor '#{s.options[:flavor]}', key '#{s.key}' and networks '#{networks.map{|n| n["name"]}.join("', '")}'...\n\n"
      compute = self.compute
      begin
        o_server = compute.create_server(s.chef_node_name, s.options[:image], s.options[:flavor],
                           "nics" => networks.map{|n| {"net_id" => n["id"]}},
                           "security_groups" => s.options[:groups],
                           "key_name" => s.key)
      rescue Excon::Errors::BadRequest => e
        response = ::Chef::JSONCompat.from_json(e.response.body)
        if response['badRequest']['code'] == 400
          if response['badRequest']['message'] =~ /Invalid flavorRef/
            out << "\nERROR: Bad request (400): Invalid flavor id specified: #{s.options[:flavor]}"
          elsif response['badRequest']['message'] =~ /Invalid imageRef/
            out << "\nERROR: Bad request (400): Invalid image specified: #{s.options[:image]}"
          else
            out << "\nERROR: Bad request (400): #{response['badRequest']['message']}"
          end
          out << "\n"
          return false
        else
          out << "\nERROR: Unknown server error (#{response['badRequest']['code']}): #{response['badRequest']['message']}"
          out << "\n"
          return false
        end
      rescue Excon::Errors::InternalServerError => ise
        out << "\nError: openstack internal server error " + ise.message
        out << "\n"
        return false
      rescue => e2
        out << "\nError: Unknown error: " + e2.message
        out << "\n"
        return false
      end
      sbody = o_server.body
      s.id = sbody["server"]["id"]

      out << "\nInstance Name: #{s.chef_node_name}"
      out << "\nInstance ID: #{s.id}\n"
      out << "\nWaiting for server..."

      details, status = nil, nil
      until status == "ACTIVE"
        sleep(1)
        details = compute.get_server_details(s.id).body
        status = details["server"]["status"].upcase
        if status == "ERROR"
          out << "Server returns status 'ERROR'"
          return false
        end
      end
      network = networks[0]["name"]
      s.private_ip = details["server"]["addresses"][network][0]["addr"]
      out << "\nDone\n\n"
      out << s.info
      true
    end

    def create_default_chef_node_name s
      "#{self.ssh_key}-#{s.project}-#{s.deploy_env}-#{Time.now.to_i}"
    end

    def delete_server s
      r = self.compute.delete_server(s.id)
      return r.status == 204 ? "Server with id '#{s.id}' terminated" : r.body
    end

    def pause_server s
      begin
        self.compute.pause_server s.id
      rescue Excon::Errors::Conflict => e
        return "pause"
      end
      return nil
    end

    def unpause_server s
      begin
        self.compute.unpause_server s.id
      rescue Excon::Errors::Conflict => e
        return "unpause"
      end
      return nil
    end

    def compute
      connection_compute(self.connection_options)
    end

    def network
      connection_network(self.connection_options)
    end
  private
    def convert_groups list
      res = {}
      list.map do |g|
        res[g["name"]] = {
          "description" => g["description"]
        }
        rules = []
        g["rules"].each do |r|
          rules.push({
            "protocol" => r["ip_protocol"],
            "from" => r["from_port"],
            "to" => r["to_port"],
            "cidr" => r["ip_range"]["cidr"]
          })
        end
        res[g["name"]]["rules"] = rules
      end
      res
    end

  end
end
