
<head>
	<meta charset="utf-8"/>
	<meta name="author" content="Anton Martynov">
	<meta name="author" content="Mike Miroliubov">
	<meta name="author" content="Alexey Lukashin">
	<title>Devops client</title>
</head>

<style>
	h1 {
		text-align: center;
	}
	h2 {
		border-bottom: 1px solid black;
	}
	h3 {
		border-bottom: 1px solid #c6c6c6;
	}
	table {
		border-collapse:collapse;
	}
	table, th, td {
		border: 1px solid #cccccc;
	}
	th, td {
		padding: 2px 10px;
	}
</style>

Devops client
=============

Devops client is a ruby gem.

## Table of contents

*	[Installation](#install)
*	[First run](#first_run)
*	[Client commands](#commands)
    *   [Templates](#templates)
    *   [Deploy](#deploy)
    *   [Filters](#filters)
    *   [Flavor](#flavor)
    *   [Group](#group)
    *   [Image](#image)
    *   [Key](#key)
    *   [Network](#network)
    *   [Project](#project)
    *   [Provider](#provider)
    *   [Script](#script)
    *   [Server](#server)
    *   [Tag](#tag)
    *   [User](#user)
*	[HOWTO](#howto)
    *   [Create user](#howto_user)
    *   [Create image](#howto_image)
    *   [Create project](#howto_project)
    *   [Launch new server](#howto_server)

<h2 id="install">Installation</h2>

Devops client requirements:

* ruby v1.9.3 or higher

Client can be installed by following command

	$ sudo gem install devops-client.gem --no-ri --no-rdoc

After gem installation new command will be available in your system

	$ devops

If command wasn't found then necessary to check ruby environment

	$ gem environment

And add "EXECUTABLE DIRECTORY" into $PATH

Devops shows help if invoked without parameters:

	$ devops

	Usage: /usr/bin/devops command [options]

	Commands:
		Bootsrap templates:
			templates list

		Deploy:
			deploy NODE_NAME [NODE_NAME ...]

		Filters:
			filter image add ec2|openstack IMAGE [IMAGE ...]
			filter image delete ec2|openstack IMAGE [IMAGE ...]
			filter image list ec2|openstack

		Flavor:
			flavor list PROVIDER

		Group:
			group list PROVIDER

		Image:
			image create
			image delete IMAGE
			image list [provider] [ec2|openstack]
			image show IMAGE
			image update IMAGE FILE

		Key:
			key add KEY_NAME FILE
			key delete KEY_NAME
			key list

		Network:
			network list PROVIDER

		Project:
			project create PROJECT_ID
			project delete PROJECT_ID [DEPLOY_ENV]
			project deploy PROJECT_ID [DEPLOY_ENV]
			project list
			project multi create PROJECT_ID
			project servers PROJECT_ID [DEPLOY_ENV]
			project set run_list PROJECT_ID DEPLOY_ENV [(recipe[mycookbook::myrecipe])|(role[myrole]) ...]
			project show PROJECT_ID
			project update PROJECT_ID FILE
			project user add PROJECT_ID USER_NAME [USER_NAME ...]
			project user delete PROJECT_ID USER_NAME [USER_NAME ...]

		Provider:
			provider list

		Script:
			script list
			script add SCRIPT_NAME FILE
			script delete SCRIPT_NAME
			script run SCRIPT_NAME NODE_NAME [NODE_NAME  ... ]
			script command NODE_NAME 'sh command'

		Server:
			server add PROJECT_ID DEPLOY_ENV IP SSH_USER KEY_ID
			server bootstrap INSTANCE_ID
			server create PROJECT_ID DEPLOY_ENV
			server delete NODE_NAME [NODE_NAME ...]
			server list [chef|ec2|openstack]
			server pause NODE_NAME
			server show NODE_NAME
			server unpause NODE_NAME

		Tag:
			tag create NODE_NAME TAG_NAME [TAG_NAME ...]
			tag delete NODE_NAME TAG_NAME [TAG_NAME ...]
			tag list NODE_NAME

		User:
			user create USER_NAME
			user delete USER_NAME
			user grant USER_NAME [COMMAND] [PRIVILEGES]
			user list
			user password USER_NAME

Detailed help for each command can be shown by passing --help to command line.

<h2 id="first_run">First run</h2>

During first, run devops will detect that its configuration file is absent and will show warning and ask for required parameters:
First step is to enter server's host and port:

		WARN: File '~/.devops/devops-client.conf' does not exist
		Language: ru
		Devops service host: <host>:7070
		Default API version (v2.0):
		Username: my_user
		Password: my_password
		Configuration file '~/.devops/devops-client.conf' is created

Also necessary to enter API version (current is v2.0) and credentials.
After these questions configuration file will be created.

<h2 id="commands">Commands</h2>

After running some commands, devops client might show information in JSON format and ask for confirmation. User can approve or decline operation.

Any command has additional options:

<table>
  <tr>
    <th>Option</th>
    <th>Desciption</th>
  </tr>
  <tr>
    <td>-h, --help</td>
    <td>Show help</td>
  </tr>
  <tr>
    <td>-c, --config FILE</td>
    <td>Specify devops client config file (/home/my_user/.devops/devops-client.conf)</td>
  </tr>
  <tr>
    <td>-v, --version</td>
    <td>devops client version</td>
  </tr>
  <tr>
    <td>--host HOST</td>
    <td>devops service host address (devops-server-host:devops-server-port)</td>
  </tr>
  <tr>
    <td>--api VER</td>
    <td>devops service API version (v2.0)</td>
  </tr>
  <tr>
    <td>--user USERNAME</td>
    <td>use USERNAME for authentication</td>
  </tr>
  <tr>
    <td>--format FORMAT</td>
    <td>Output format: 'table', 'json' (table)</td>
  </tr>
  <tr>
    <td>--completion</td>
    <td>Initialize bash completion script</td>
  </tr>
</table>

<h3 id="templates">Templates</h3>

	$ devops templates

	Usage: /usr/bin/devops command [options]

	Commands:
		Bootsrap templates:
			templates list

**devops templates list** - command will list available templates for bootstrapping virtual machines by Chef

<h3 id="deploy">Deploy</h3>

Command performs deployment operation by running Chef client on remote server

	$ devops deploy

	Usage: /usr/bin/devops command [options]

	Commands:
		Deploy:
			deploy NODE_NAME [NODE_NAME ...]

**devops deploy** - deploys everything on server

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--tag TAG1,TAG2...</td>
    <td>Chef tag names, comma separated list of a tags which will be temporary applied to servers.</td>
  </tr>
</table>

<h3 id="filters">Filters</h3>

Filters allows to specify cloud VM images and restrict devops to use only them. It is helpful in case of EC2 which has hungreds of images.

	$ devops filter

	Usage: /usr/bin/devops command [options]

	Commands:
		Filters:
			filter image add ec2|openstack IMAGE [IMAGE ...]
			filter image delete ec2|openstack IMAGE [IMAGE ...]
			filter image list ec2|openstack

**devops filter image add** - adds image id to filters
**devops filter image delete** - removes image id (ids) from filters
**devops filter image list** - shows list of available images

<h3 id="flavor">Flavor</h3>

	$ devops flavor

	Usage: /usr/bin/devops command [options]

	Commands:
		Flavor:
			flavor list PROVIDER

**devops flavor list** - lists available virtual machine configurations

<h3 id="group">Group</h3>

	$ devops group

	Usage: /usr/bin/devops command [options]

	Commands:
		Group:
			group list PROVIDER

**devops group list** - displays list of security groups

<h3 id="image">Image</h3>

Command allows managing virtual machine images.

	$ devops image

	Usage: /usr/bin/devops command [options]

	Commands:
		Image:
			image create
			image delete IMAGE
			image list [provider] [ec2|openstack]
			image show IMAGE
			image update IMAGE FILE

**devops image create** - creates image. Client will ask several questions:

	Provider:                      # select cloud provider (e.g., openstack, ec2)
	Choose image:                  # enter image number from a list
	The ssh username:              # give ssh username for logging in
	Bootstrap template (optional): # select bootstrap template

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--provider PROVIDER</td>
    <td>Image provider</td>
  </tr>
  <tr>
    <td>--image IMAGE_ID</td>
    <td>Image identifier</td>
  </tr>
  <tr>
    <td>--ssh_user USER</td>
    <td>SSH user name</td>
  </tr>
  <tr>
    <td>--bootstrap_template TEMPLATE</td>
    <td>Bootstrap template</td>
  </tr>
  <tr>
    <td>--no_bootstrap_template</td>
    <td>Do not specify bootstrap template</td>
  </tr>
</table>

**devops delete** - delete image by ID

**devops image list** - list available images

**devops image list provider ec2|openstack** - list available cloud images (filtered by devops)

**devops image list ec2|openstack** - list available images

**devops image show** - show image information

**devops image update** - update image from provided JSON file

<h3 id="key">Key</h3>

Manage keys (SSH certificates) servers.

	Key:
			key add KEY_NAME FILE
			key delete KEY_NAME
			key list

**devops key add** - adds new key with given name KEY_NAME from file FILE

**devops key delete** - remove key with name KEY_NAME

**devops key list** - lists available keys

There is at least one system key which cannot be deleted by user. System keys are registered during devops server configuration and not manageable by user)

<h3 id="network">Network</h3>

	$ devops network

	Usage: /usr/bin/devops command [options]

	Commands:
		Network:
			network list PROVIDER

**devops network list PROVIDER** - list available cloud networks for given PROVIDER

<h3 id="project">Project</h3>

Command allows to manage projects

	$ devops project

	Usage: /usr/bin/devops command [options]

	Commands:
		Project:
			project create PROJECT_ID
			project delete PROJECT_ID [DEPLOY_ENV]
			project deploy PROJECT_ID [DEPLOY_ENV]
			project list
			project servers PROJECT_ID [DEPLOY_ENV]
			project set run_list PROJECT_ID DEPLOY_ENV [(recipe[mycookbook::myrecipe])|(role[myrole]) ...]
			project show PROJECT_ID
			project update PROJECT_ID FILE
			project user add PROJECT_ID USER_NAME [USER_NAME  ...]
			project user delete PROJECT_ID USER_NAME [USER_NAME  ...]

**devops project create** - create a new project

Client will ask several questions:
	Deploy environment identifier:                                                               # which environment will be created  (dev, test, my_env...) At least one environment required for project.
	Provider:                                                                                    # Cloud provider (openstack, amazon ec2)
	Security groups (comma separated), like 1,2,3, or empty for 'default':                       # List of security groups which will be assigned to new VMs in given environment/
	Users, you will be added automatically (comma separated), like 1,2,3, or empty:              # list of users
	Flavor:                                                                                      # server configuration
	Image:                                                                                       # image for virtual machine
	Subnets (comma separated), like 1,2,3, or empty:                                             # cloud subnets (openstack or Amazon VPC requires at least one)
	Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]: role[test_dev], # roles and cookbooks which will be assigned to virtual machines
	Enter expires time if necessary (5m, 3h, 2d, 1w, etc):                                       # virtual machine life time (by default forever)

*If project already exists then new environment will be added to it*

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--groups GROUP_1,GROUP_2...</td>
    <td>Security groups (comma separated list)</td>
  </tr>
  <tr>
    <td>--deploy_env DEPLOY_ID</td>
    <td>Deploy enviroment identifier</td>
  </tr>
  <tr>
    <td>--subnets SUBNET,SUBNET...</td>
    <td>Subnets identifier for deploy enviroment (ec2 - only one sybnet, openstack - comma separated list)</td>
  </tr>
  <tr>
    <td>--flavor FLAVOR</td>
    <td>Specify flavor for the project</td>
  </tr>
  <tr>
    <td>--image IMAGE_ID</td>
    <td>Specify image identifier for the project</td>
  </tr>
  <tr>
    <td>--run_list RUN_LIST</td>
    <td>Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]:</td>
  </tr>
  <tr>
    <td>--users USER,USER...</td>
    <td>Users for deploy environment control</td>
  </tr>
  <tr>
    <td>--provider PROVIDER</td>
    <td>Provider identifier 'ec2' or 'openstack'</td>
  </tr>
  <tr>
    <td>--no_expires</td>
    <td>Without expires time</td>
  </tr>
  <tr>
    <td>--expires EXPIRES</td>
    <td>Expires time (5m, 3h, 2d, 1w, etc)</td>
  </tr>
</table>

**devops project delete** - removes project or its environment

**devops project deploy** - deploys to all servers in a project or in given environment

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Desciption</th>
  </tr>
  <tr>
    <td>--servers SERVERS</td>
    <td>Servers list (comma separated)</td>
  </tr>
</table>

**devops project list** - list all available projects

**devops project servers** - list all running servers in a project

**devops project set run_list** - update run-list for a project's environment

**devops project show** - display project info

**devops project update** - update project from JSON file

**devops project user delete** - add user to project

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--deploy_env ENV</td>
    <td>Add user to deploy enviroment</td>
  </tr>
</table>

**devops project user delete** - remove user(s) from a project

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--deploy_env ENV</td>
    <td>Add user to deploy enviroment</td>
  </tr>
</table>

<h3 id="provider">Provider</h3>

	$ devops provider

	Usage: /usr/bin/devops command [options]

	Commands:
		Provider:
			provider list

**devops provider list** - Lists available cloud providers registered on devops server

<h3 id="script">Script</h3>

Manages shell scrips for running on servers

	$ devops script

	Usage: /usr/bin/devops command [options]

	Commands:
		Script:
			script list
			script add SCRIPT_NAME FILE
			script delete SCRIPT_NAME
			script run SCRIPT_NAME NODE_NAME [NODE_NAME  ...]
			script command NODE_NAME 'sh command'

**devops script list** - lists available scripts

**devops script add** - adds new script with name SCRIPT_NAME from file FILE

**devops script delete** - removes script SCRIPT_NAME

**devops script run** - runs script with name SCRIPT_NAME on server with node name (on Chef server) NODE_NAME

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--params PARAMS</td>
    <td>Comma separated scipt parameters</td>
  </tr>
</table>

**devops script command** - run shell command on remote server (bash interpreter is used)

<h3 id="server">Server</h3>

	$ devops server

	Usage: /usr/bin/devops command [options]

	Commands:
		Server:
			server add PROJECT_ID DEPLOY_ENV IP SSH_USER KEY_ID
			server bootstrap INSTANCE_ID
			server create PROJECT_ID DEPLOY_ENV
			server delete NODE_NAME [NODE_NAME ...]
			server list [chef|ec2|openstack]
			server pause NODE_NAME
			server show NODE_NAME
			server unpause NODE_NAME

**devops server add** - adds new server (bare metal, existing,...) to a project with name PROJECT_ID

**devops server bootstrap** - bootstraps chef on server and runs Chef client with project run list

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>-N, --name NAME</td>
    <td>Set chef name</td>
  </tr>
  <tr>
    <td>--bootstrap_template [TEMPLATE]</td>
    <td>Bootstrap template (optional)</td>
  </tr>
</table>

**devops server create** - launches new server in a cloud with project PROJECT_ID and environment DEPLOY_ENV

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>-N, --name NAME</td>
    <td>Set chef name</td>
  </tr>
</table>

**devops server delete** - terminates server

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--instance</td>
    <td>Delete node by instance id</td>
  </tr>
</table>

**devops server list** - list servers

**devops server pause** - put server on pause (only if cloud provider supports it)

**devops server show** - show detailed information

**server unpause** - unpause server

<h3 id="tag">Tag</h3>

Manages tags on Chef servers. This functionality can be used for changing deploy behavior according to given tags.

	$ devops tag

	Usage: /usr/bin/devops command [options]

	Commands:
		Tag:
			tag create NODE_NAME TAG_NAME [TAG_NAME ...]
			tag delete NODE_NAME TAG_NAME [TAG_NAME ...]
			tag list NODE_NAME

**devops tag create** - create new tag on chef node with name NODE_NAME

**devops tag delete** - removes tag from chef node with name NODE_NAME

**devops tag list** - lists all tags on a chef node with name NODE_NAME

<h3 id="user">User</h3>

User management

	$ devops user

	Usage: /usr/bin/devops command [options]

	Commands:
		User:
			user create USER_NAME
			user delete USER_NAME
			user grant USER_NAME [COMMAND] [PRIVILEGES]
			user list
			user password USER_NAME

**devops user create** - create user with name USER_NAME

Options:

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>--password PASSWORD</td>
    <td>New user password</td>
  </tr>
</table>

**devops user delete** - remove user with name USER_NAME

**devops user grant** - grants permissions for user

Available subcommands:

*	all
*	flavor
*	group
*	image
*	project
*	server
*	key
*	user
*	filter
*	network
*	provider
*	script

Available privileges:

*	r
*	w
*	rw

If privileges are not specified then user is not allowed to run command.

If command and privileges are not specified then user's permissions are set to default values.

**devops user list** - list all users

**devops user password** - change user's password

<h1 id="howto">Mini HOWTO</h1>

Mostly used scenarios described below.


<h2 id="howto_user">User management</h2>

After clean install root user has empty password, lets set it:

	$ devops user password root -u root
	Enter password for 'root':
	Updated

Let's create user test and grant some permissions for working with filters, images, projects and servers:

If system doesn't have users then let's use root user:

	$ devops user create test -u root
	Password for root:
	Enter password for 'test':
	Created

By default user has read permissions for filter, image, project, and server operations. Lets give him write permissions:

	$ devops user grant test filter rw -u root
	Password for root:
	Updated

	$ devops user grant test image rw -u root
	Password for root:
	Updated

	$ devops user grant test project rw -u root
	Password for root:
	Updated

	$ devops user grant test server rw -u root
	Password for root:
	Updated

	$ devops user grant test user r -u root
	Password for root:
	Updated


<h2 id="howto_image">Image management</h2>

First step is to add required images to filter. For OpenStack it is OpenStack image id, for EC2 it is AMI.

	devops filter image add openstack 78665e7b-5123-4fa8-b39b-d7643ecd8ed7

Next step is to create image and specify required metadata:

	$ devops image create
	+--------+-----------+
	| API version: v2.0  |
	|      Provider      |
	+--------+-----------+
	| Number | Provider  |
	+--------+-----------+
	| 1      | ec2       |
	| 2      | openstack |
	+--------+-----------+
	Provider: 2
	+--------+---------------------------+--------------------------------------+--------+
	|                                 API version: v2.0                                  |
	|                                       Images                                       |
	+--------+---------------------------+--------------------------------------+--------+
	| Number | Name                      | ID                                   | Status |
	+--------+---------------------------+--------------------------------------+--------+
	| 1      | centos-6.4-amd64-20130707 | 78665e7b-5123-4fa8-b39b-d7643ecd8ed7 | ACTIVE |
	+--------+---------------------------+--------------------------------------+--------+
	Image: 1
	The ssh username: root
	Bootstrap template (optional):
	{
	  "provider": "openstack",
	  "name": "centos-6.4-amd64-20130707",
	  "id": "78665e7b-5123-4fa8-b39b-d7643ecd8ed7",
	  "remote_user": "root"
	}
	Create image? (y/n):

<h2 id="howto_project">Project management</h2>

Let's create new project 'my_project' with environment 'test'

	$ devops project create my_project
	Deploy environment identifier: test
	+--------+-----------+
	| API version: v2.0  |
	|      Provider      |
	+--------+-----------+
	| Number | Provider  |
	+--------+-----------+
	| 1      | ec2       |
	| 2      | openstack |
	+--------+-----------+
	Provider: 2

System will show security groups. We are selecting what is needed:

	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	|                                                API version: v2.0                                                 |
	|                                                      Groups                                                      |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| Number | Name                                | Protocol | From | To    | CIDR      | Description                 |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| 1      | default                             | udp      | 1    | 65535 | 0.0.0.0/0 | default                     |
	|        |                                     | tcp      | 1    | 65535 | 0.0.0.0/0 |                             |
	|        |                                     | icmp     | -1   | -1    | 0.0.0.0/0 |                             |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	| 2      | webports                            | tcp      | 8080 | 8080  | 0.0.0.0/0 | web ports                   |
	|        |                                     | tcp      | 80   | 80    | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 8089 | 8089  | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 8443 | 8443  | 0.0.0.0/0 |                             |
	|        |                                     | tcp      | 443  | 443   | 0.0.0.0/0 |                             |
	+--------+-------------------------------------+----------+------+-------+-----------+-----------------------------+
	Security groups (comma separated), like 1,2,3, or empty for 'default':

Next step is to users which can work with a project:

	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	|                                                     API version: v2.0                                                     |
	|                                                           Users                                                           |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	|        |                  |                                          Privileges                                           |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| Number | User ID          | Image | Key | Project | Server | User | Script | Filter | Flavor | Group | Network | Provider |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| 1      | test             | rw    | r   | rw      | rw     | r    | r      | rw     | r      | r     | r       | r        |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	| 2      | root             | rw    | rw  | rw      | rw     | rw   | rw     | rw     | rw     | rw    | rw      | rw       |
	+--------+------------------+-------+-----+---------+--------+------+--------+--------+--------+-------+---------+----------+
	Users, you will be added automatically (comma separated), like 1,2,3, or empty:

Flavor for environment:

	+--------+-----------+--------------+------+-------+
	|                API version: v2.0                 |
	|                     Flavors                      |
	+--------+-----------+--------------+------+-------+
	| Number | ID        | Virtual CPUs | Disk | RAM   |
	+--------+-----------+--------------+------+-------+
	| 1      | c1.large  | 8            | 50   | 8192  |
	| 2      | c1.medium | 2            | 50   | 2048  |
	| 3      | c1.small  | 2            | 20   | 1024  |
	| 4      | c2.long   | 2            | 120  | 4096  |
	| 5      | m1.large  | 4            | 80   | 8192  |
	| 6      | m1.medium | 2            | 40   | 4096  |
	| 7      | m1.small  | 1            | 20   | 2048  |
	| 8      | m1.tiny   | 1            | 3    | 512   |
	| 9      | m1.xlarge | 8            | 160  | 16384 |
	| 10     | m2.long   | 2            | 60   | 2048  |
	| 11     | snapshot  | 2            | 42   | 2048  |
	+--------+-----------+--------------+------+-------+
	Flavor: 7

Image for virtual machines:

	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	|                                                    API version: v2.0                                                     |
	|                                                          Images                                                          |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	| Number | ID                                   | Name                      | Bootstrap template | Remote user | Provider  |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	| 1      | 78665e7b-5123-4fa8-b39b-d7643ecd8ed7 | centos-6.4-amd64-20130707 |                    | root        | openstack |
	+--------+--------------------------------------+---------------------------+--------------------+-------------+-----------+
	Image: 1

Network for a virtual machine:

	+--------+--------------+-----------------+
	|            API version: v2.0            |
	|                 Subnets                 |
	+--------+--------------+-----------------+
	| Number | Name         | CIDR            |
	+--------+--------------+-----------------+
	| 1      | 172.16.223.0 | 172.16.223.0/24 |
	| 2      | 172.16.227.0 | 172.16.227.0/24 |
	| 3      | LocalNetwork | 172.16.37.0/24  |
	| 4      | LocalNetwork | 10.1.98.0/24    |
	| 5      | private      | 10.0.0.0/24     |
	+--------+--------------+-----------------+
	Subnets (comma separated), like 1,2,3, or empty: 5

Chef roles for project and environment. By default will be created new role with name PROJECT-ENV and added to runlist. Additional roles and recipes can be specified here.

	Run list (comma separated), like recipe[mycookbook::myrecipe], role[myrole]: role[my_project_test],

Just press enter if server lifetime should be infinite.

	Enter expires time if necessary (5m, 3h, 2d, 1w, etc):

Assume that we do not need second environment. Just press 'n' here.

	Add deploy environment? (y/n): n
	{
	  "deploy_envs": [
	    {
	      "identifier": "test",
	      "provider": "openstack",
	      "groups": [
	        "default"
	      ],
	      "users": [
	        "test"
	      ],
	      "flavor": "m1.small",
	      "image": "78665e7b-5123-4fa8-b39b-d7643ecd8ed7",
	      "subnets": [
	        "private"
	      ],
	      "run_list": [
	        "role[my_project_test]"
	      ],
	      "expires": null
	    }
	  ],
	  "name": "my_project"
	}
	Create project? (y/n):


Last question allows reviewing details and confirming for project creation.

<h2 id="howto_server">Starting new instance</h2>

After that we can create servers and apply chef roles:

	devops server create my_project test -N my_server_1

'-N' parameter allows to specify chef node name. By default node name will be generated automatically.
