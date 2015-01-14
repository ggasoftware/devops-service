# Stub some methods in Ec2 Provider

puts '!!! WARNING !!!'
puts '!!! Some EC2 methods are stubbed !!!'

class Provider::Ec2

  def groups filter=nil
    {
      'test' => {
        'description' => 'Description',
        'rules' =>  [{
          "protocol" => "ip_protocol",
          "from" => "from_port",
          "to" => "to_port",
          "cidr" => "cidr"
        }]
      },
      'default' => {
        'description' => 'Description',
        'rules' =>  [{
          "protocol" => "ip_protocol",
          "from" => "from_port",
          "to" => "to_port",
          "cidr" => "cidr"
        }]
      }
    }
  end

  def flavors
    [{
      "id" => 'test_flavor',
      "v_cpus" => 2,
      "ram" => 256,
      "disk" => 1000
    }]
  end

  def images filters
    [
      {
        "id" => 'test_image_ec2',
        "name" => 'test image',
        "status" => 'test status'
      }
    ]
  end

  def networks
    networks_detail
  end

  def networks_detail
    [
      {
        'cidr' => '192.0.2.32/27',
        'vpcId' => 'test_network_id',
        'subnetId' => 'test_network_id',
        'name' => 'test_network_id',
        'zone' => 'test_zone'

      }
    ]
  end

end