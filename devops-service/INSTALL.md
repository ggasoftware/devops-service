Installation guide
=============

This is the installation guide of the devops server.

## Contents

* [Software requirements](#software)
    * [RHEL-based systems](#rhel)
    * [Debian-based systems](#debian)
* [System users](#users)
* [Directories](#directories)
* [RVM](#rvm)
* [Downloads](#downloads)
* [Gems](#gems)
* [SSH configuration](#ssh)
* [Knife configuration](#knife)
* [Devops configuration](#clouds)
    * [Openstack](#cloud_openstack)
    * [Ec2](#cloud_ec2)
* [Init script](#init)
* [Run devops](#run)

<h2 id="software">Software requirements</h2>

Before installing devops, you should install system requirements: bash, gcc, make, wget, unzip, libxml2, libxslt

<h3 id="rhel">RHEL-based systems</h3>

	# yum install -y bash gcc make wget unzip gcc-c++ libxml2-devel libxslt-devel

<h3 id="debian">Debian-based systems</h3>

	# apt-get install bash gcc make wget unzip g++ libxml2-dev libxslt-dev

<h2 id="users">System users</h2>

Create user devops

	# useradd -m -d /devops --system -s /bin/bash devops

<h2 id="directories">Directories</h2>

Create log directory:

	# mkdir -p /var/log/devops
	# chown devops: /var/log/devops

Create pid directory:

	# mkdir -p /var/run/devops
	# chown devops: /var/run/devops

Create devops directory:

	# mkdir -p /devops/devops
	# chown devops: /devops/devops

Create ssh, chef directories:

	# mkdir -p /devops/{.ssh,.chef}
	# chown devops: /devops/{.ssh,.chef}

Create bootstrap directory

	# mkdir -p /devops/.chef/bootstrap
	# chown devops: /devops/.chef/bootstrap

Create devops public directory:

	# mkdir -p /devops/devops/public
	# chown devops: /devops/devops/public

<h2 id="rvm">RVM</h2>

You should install rvm with ruby 1.9 or use system ruby

<h2 id="downloads">Downloads</h2>

Download devops-service-master.zip from https://github.com/ggasoftware/devops-service into /tmp
Unzip devops-service-master.zip

	# unzip /tmp/devops-service-master.zip -d /tmp/

Copy devops-service

	# cp -rf /tmp/devops-service-master/devops-service/* /devops/devops
	# chown devops: -R /devops/devops

Create client gem

	# cd /tmp/devops-service-master/devops-client/
	# rake build
	# cp pkg/devops-client*.gem /devops/devops/public/devops-client.gem
	# chown devops: /devops/devops/public/devops-client.gem

<h2 id="gems">Gems</h2>

Install bundler

	# gem install bundler

Then run bundler

	# cd /devops/devops && bundle install

<h2 id="ssh">SSH configuration</h2>

	# cat /devops/.ssh/config
	StrictHostKeyChecking no
	UserKnownHostsFile /dev/null

<h2 id="knife">Knife configuration</h2>

	# cat /devops/.chef/knife.rb
	log_level                :info
	log_location             STDOUT
	node_name                "devops"
	chef_server_url          "<Chef server host>"
	validation_client_name   "chef-validator"
	client_key               "/devops/.chef/client.pem"
	validation_key           "/devops/.chef/validation.pem"

Then you should create client 'devops' with admin privileges on your chef server and copy your client.pem and validation.pem into /devops/.chef

	chown devops: /devops/.chef/client.pem
	chmod 0600 /devops/.chef/client.pem
	chown devops: /devops/.chef/validation.pem
	chmod 0600 /devops/.chef/validation.pem

<h2 id="configuration">Devops configuration</h2>

Devops configuration file is /devops/devops/config.rb

	# cat /devops/devops/config.rb
	config[:knife_config_file] = "/devops/.chef/knife.rb"
	config[:role_separator] = "_"
	config[:mongo_host] = "<mongo host>"
	config[:mongo_port] = 27017
	config[:mongo_db] = "<mongo db name>"
	config[:mongo_user] = "<mongo user name>"
	config[:mongo_password] = "<mongo user password>"
	config[:port] = 7070
	config[:client_file] = "/devops/devops/public/devops-client.gem"
	config[:public_dir] = "/devops/devops/public"

<h3 id="cloud_openstack">Openstack</h3>

To configure openstack cloud, you should add to /devops/devops/config.rb:

	config[:openstack_username]    = "<username>"
	config[:openstack_api_key]     = "<password>"
	config[:openstack_auth_url]    = "http://<host>:5000/v2.0/tokens"
	config[:openstack_tenant]      = "<tenant>"
	config[:openstack_ssh_key]     = "<ssh key>"
	config[:openstack_certificate] = "/devops/.ssh/openstack.pem"

And copy your openstack certificate 'openstack.pem' into /devops/.ssh/

<h3 id="cloud_ec2">Ec2</h3>

To configure ec2 cloud, you should add to /devops/devops/config.rb:

	config[:aws_access_key_id]     = "<access key id>"
	config[:aws_secret_access_key] = "<secret access key"
	config[:aws_ssh_key]           = "<ssh key>"
	config[:aws_certificate]       = "/devops/.ssh/ec2.pem"
	config[:aws_availability_zone] = "us-east-1e"

And copy your ec2 certificate 'ec2.pem' into /devops/.ssh/

<h2 id="init">Init script</h2>

	# cat /etc/init.d/devops_service
	#!/bin/bash
	#
	# devops_service: Start/Stop devops service
	#
	# chkconfig: - 80 05
	# description: Enable devops service
	user=devops
	devops_home=/devops/devops
	pid_file=/var/run/devops/devops.pid
	log_file=/var/log/devops/service.log
	port=7070
	env=production
	start() {
	  echo "Starting devops service"
	  PIDDIR=`dirname $pid_file`
	  if [ ! -d $PIDDIR ]; then
	    mkdir -p $PIDDIR
	    chown $user $PIDDIR
	  fi
	  su - $user -c "cd $devops_home && bundle exec thin -R $devops_home/config.ru -e $env -d -p $port -t 600 -u $user --pid $pid_file --log $log_file start"
	  return $?
	}
	stop() {
	  echo "Stopping devops service"
	  su - $user -c "cd $devops_home && bundle exec thin --pid $pid_file stop"
	}
	status() {
	  if [ -f $pid_file ]; then
	    pid=`cat $pid_file`
	    echo "Running with pid: $pid"
	  else
	    echo "Not running"
	  fi
	  return $?
	}
	case "$1" in
	  start)
	    start
	    ;;
	  stop)
	    stop
	    ;;
	  restart)
	    stop
	    start
	    ;;
	  status)
	    status
	    ;;
	  *)
	    echo "Usage: $0 (start|stop|restart|status)"
	    exit 1
	esac
	exit $?

<h2 id="run">Run devops</h2>

Before run devops, check or disable iptables

	chmod +x /etc/init.d/devops_service
	/etc/init.d/devops_service start
