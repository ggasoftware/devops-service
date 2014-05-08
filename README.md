# Devops services#

Copyright (c) 2009-2014 GGA Software Services LLC

Authors: Anton Martynov, Mikhail Mirolyubov, Alexey Lukashin

##Introduction##

This software was developed for supporting development and operations activities. This service allows managing servers and deployments in hybrid computing environment such as combination of Amazon EC2, VPC, and OpenStack clouds as well as bare metal servers. Deployment is performed by using Opscode Chef Server. The general idea is to put all software dependencies and deployment scripts into chef recipes and apply these procedures to the server.

##Devops-service installation##

Devops service is a REST web service which incapsulates all apllication logic.

Setup server:
	yum install ruby
	yum install ruby-devel
	yum install libxml2-devel
	yum install libxslt-devel
	yum install gcc make
	yum install wget
	wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.24.tgz
	tar xvf rubygems-1.8.24.tgz
	cd rubygems-1.8.24
	ruby setup.rb
	gem install knife-openstack -sinatra thin --no-ri --no-rdoc

Run server:
	ruby -rubygems devops-service.rb

The deep configuration of Devops Service is performed by Chef cookbook.

##Devops-client installation##

Devops client is a ruby gem, which provides CLI application for interaction with Devops Service.

Dependencies:
	gems:
		httpclient >= 2.3
		json
		terminal-table

gem install devops-client.gem


## License

Devops-service software is released under the [MIT License](http://www.opensource.org/licenses/MIT).
