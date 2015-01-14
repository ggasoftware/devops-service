# path to log file
config[:log_file] = "/path/to/log"
# path to chef knife.rb file
config[:knife_config_file] = "/path/to/.chef/knife.rb"
# role name separator
config[:role_separator] = "_"

# mongodb settings
config[:mongo_host] = "localhost"
config[:mongo_port] = 27017
config[:mongo_db] = "devops"
config[:mongo_user] = "user"
config[:mongo_password] = "pass"

# devops port
config[:port] = 7070

# path to devops-client.gem file
config[:client_file] = "/path/to/public/devops-client.gem"
# path to devops public directory
config[:public_dir] = "/path/to/public"

# openstack settings
config[:openstack_username] = "openstack_username"
config[:openstack_api_key] = "openstack_pass"
config[:openstack_auth_url] = "http://openstack.host:5000/v2.0/tokens"
config[:openstack_tenant]   = "tenant"
config[:openstack_ssh_key]   = "ssh_key"
config[:openstack_certificate]   = "/path/to/.ssh/openstack.pem"

# aws settings
config[:aws_access_key_id] = "access_key_id"
config[:aws_secret_access_key] = "secret_access_key"
config[:aws_ssh_key]   = "ssh_key"
config[:aws_certificate]   = "/path/to/.ssh/ec2.pem"
config[:aws_availability_zone]   = "aws_zone"

# static settings
config[:static_ssh_key]   = "ssh_key" # or nil
config[:static_certificate]   = "/path/to/.ssh/static.pem"
