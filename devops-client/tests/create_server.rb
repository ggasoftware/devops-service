require "./base_test"
require "json"

class CreateServer < BaseTest
  TITLE = "Create server tests. "

  def run
    openstack = {
      :name => "openstack",
      :image => "36dc7618-4178-4e29-be43-286fbfe90f50",
      :flavor => "m1.small",
      :ssh_user => "root",
      :server_name => "test_create_server_openstack",
      :states => {:pause => "PAUSED", :unpause => "ACTIVE"}
    }
    ec2 = {
      :name => "ec2",
      :image => "ami-83e4bcea",
      :flavor => "m1.small",
      :ssh_user => "ec2-user",
      :server_name => "test_create_server_ec2",
      :states => {:pause => "stopped", :unpause => "running"}
    }

    project = {
      "name" => "project_test",
      "deploy_envs" => [
        {
          "flavor" => openstack[:flavor],
          "groups" => [
            "default"
          ],
          "identifier" =>  "openstack",
          "image" => openstack[:image],
          "provider" => "openstack",
          "run_list" => [
            "role[project_test_openstack]"
          ],
          "subnets" => [ "private" ],
          "users" => [ "user_for_testing" ],
          "expires" => nil
        },
        {
          "flavor" => ec2[:flavor],
          "groups" => [
            "default"
          ],
          "identifier" => "ec2",
          "image" => ec2[:image],
          "provider" => "ec2",
          "run_list" => [
            "role[project_test_ec2]"
          ],
          "subnets" => [],
          "users" => [ "user_for_testing" ],
          "expires" => nil
        }

      ]
    }

    self.config = CONFIGS[0]

    prepare openstack
    prepare ec2

    env_os = project["deploy_envs"][0]
    env_ec2 = project["deploy_envs"][1]
    self.title = TITLE + "Create project '#{project["name"]}'"
    run_tests [
      "project create #{project["name"]} --groups #{env_os["groups"].join(",")} --deploy_env #{env_os["identifier"]} --subnets #{env_os["subnets"].join(",")} --flavor #{env_os["flavor"]} --image #{env_os["image"]} --run_list role[#{project["name"]}_#{env_os["identifier"]}] --users #{env_os["users"].join(",")} --provider openstack -y --no_expires",
      "project create #{project["name"]} --groups #{env_ec2["groups"].join(",")} --deploy_env #{env_ec2["identifier"]} --flavor #{env_ec2["flavor"]} --image #{env_ec2["image"]} --run_list role[#{project["name"]}_#{env_ec2["identifier"]}] --users #{env_ec2["users"].join(",")} --provider ec2 -y --no_expires"
    ]

    self.title = TITLE + "Project list"
    run_test_with_block "project list --format json" do |l|
      projects = JSON.parse(l)
      projects.include? project["name"]
    end

    self.title = TITLE + "Show project '#{project["name"]}'"
    run_test_with_block "project show #{project["name"]} --format json" do |p|
      pr = JSON.parse(p)
      name = (project["name"] == pr["name"])
      envs = (project["deploy_envs"].size == pr["deploy_envs"].size)
      o = pr["deploy_envs"].detect{|e| e["identifier"] == "openstack"}
      po = project["deploy_envs"][0]
      e = pr["deploy_envs"].detect{|e| e["identifier"] == "ec2"}
      pe = project["deploy_envs"][1]
      unless name
        puts "Project name is not a '#{project["name"]}'"
      end
      unless envs
        puts "Project environments not equals #{project["deploy_envs"].size}"
      end
      name and envs and check_envs(po, o) and check_envs(pe, e)
    end

    self.title = TITLE + "Add user 'root' to project '#{project["name"]}'"
    run_tests [ "project user add #{project["name"]} root" ]

    self.title = TITLE + "Show project '#{project["name"]}' with user 'root'"
    run_test_with_block "project show #{project["name"]} --format json" do |p|
      pr = JSON.parse(p)
      envs = true
      pr["deploy_envs"].each {|e| envs = (envs and e["users"].include?("root"))}
      envs
    end

    self.title = TITLE + "Delete user 'root' from project '#{project["name"]}'"
    run_tests [ "project user delete #{project["name"]} root -y" ]

    self.title = TITLE + "Show project '#{project["name"]}' without user 'root'"
    run_test_with_block "project show #{project["name"]} --format json" do |p|
      pr = JSON.parse(p)
      envs = true
      pr["deploy_envs"].each {|e| envs = (envs and !e["users"].include?("root"))}
      envs
    end

    create_server project["name"], env_os["identifier"], openstack
    create_server project["name"], env_ec2["identifier"], ec2

    self.title = TITLE + "Delete project '#{project["name"]}'"
    run_tests [ "project delete #{project["name"]} -y" ]

    clear openstack
    clear ec2

  end

  def check_envs origin, created
    r = true
    %w(flavor groups identifier image provider run_list subnets users expires).each do |key|
      flag = (origin[key] == created[key])
      unless flag
        puts "Environments params '#{key}' not equals ('#{origin[key].inspect}' and '#{created[key].inspect}')"
      end
      r = r and flag
    end
    r
  end

  def prepare conf
    name = conf[:name]
    self.title = TITLE + "Check #{name} flavor"
    run_test_with_block "flavor list #{name} --format json" do |f|
      flavors = JSON.parse(f)
      !flavors.detect{|o| o["id"] == conf[:flavor]}.nil?
    end

    image_in_filter = false
    self.title = TITLE + "Check #{name} filter"
    run_test_with_block "filter image list #{name} --format json" do |i|
      images = JSON.parse(i)
      image_in_filter = !images.index(conf[:image]).nil?
      true
    end

    if image_in_filter
      puts_warn "Image '#{conf[:image]}' for '#{name}' already in filter"
    else
      self.title = TITLE + "Add #{name} filter"
      run_tests [ "filter image add #{name} #{conf[:image]}" ]
    end

    image_created = false
    self.title = TITLE + "Check image for #{name}"
    run_test_with_block "image list #{name} --format json" do |s|
      images = JSON.parse s
      image_created = !images.detect{|i| i["id"] == conf[:image]}.nil?
      true
    end

    if image_created
      puts_warn "Image '#{conf[:image]}' for '#{name}' already created"
    else
      self.title = TITLE + "Create image for #{name}"
      run_tests [ "image create --image #{conf[:image]} --ssh_user #{conf[:ssh_user]} --provider #{name} --no_bootstrap_template -y" ]
    end

  end

  def create_server project, env, conf

    self.title = TITLE + "Create server '#{conf[:server_name]}'"
    run_tests [ "server create #{project} #{env} -N #{conf[:server_name]}" ]

    self.title = TITLE + "Is server '#{conf[:server_name]}' created"
    run_test_with_block "server list --format json" do |l|
      servers = JSON.parse l
      !servers.detect{|s| s["chef_node_name"] == conf[:server_name].to_s }.nil?
    end

    self.title = TITLE + "Pause server '#{conf[:server_name]}'"
    run_tests [ "server pause #{conf[:server_name]}" ]
    delay = (conf[:name] == "openstack" ? 5 : 90)
    puts "Sleeping for #{delay} seconds"
    sleep(delay)

    self.title = TITLE + "Check server '#{conf[:server_name]}' state"
    run_test_with_block "server list #{conf[:name]} --format json" do |s|
      servers = JSON.parse s
      state = servers.detect{|o| o["name"] == conf[:server_name]}["state"]
      if state == conf[:states][:pause]
        true
      else
        puts_error "State should be '#{conf[:states][:pause]}' but it is '#{state}'"
        false
      end
    end

    self.title = TITLE + "Unpause server '#{conf[:server_name]}'"
    run_tests [ "server unpause #{conf[:server_name]}" ]
    delay = (conf[:name] == "openstack" ? 5 : 90)
    puts "Sleeping for #{delay} seconds"
    sleep(delay)

    self.title = TITLE + "Check server '#{conf[:server_name]}' state"
    run_test_with_block "server list #{conf[:name]} --format json" do |s|
      servers = JSON.parse s
      state = servers.detect{|o| o["name"] == conf[:server_name]}["state"]
      if state == conf[:states][:unpause]
        true
      else
        puts_error "State should be '#{conf[:states][:unpause]}' but it is '#{state}'"
        false
      end
    end

    tag = "tag_" + conf[:name]
    self.title = TITLE + "Add tag '#{tag}' to server '#{conf[:server_name]}'"
    run_tests [
      "tag create #{conf[:server_name]} #{tag}",
      "tag create #{conf[:server_name]} #{tag}"
    ]
    self.title = TITLE + "Check tag '#{tag}' for server '#{conf[:server_name]}'"
    run_test_with_block "tag list #{conf[:server_name]} --format json" do |t|
      JSON.parse(t).include?(tag)
    end

    tag2 = tag + "_2"
    self.title = TITLE + "Check deploy with tag '#{tag2}' for server '#{conf[:server_name]}'"
    run_tests ["deploy #{conf[:server_name]} -t #{tag2}"]

    self.title = TITLE + "Check tag '#{tag}' for server '#{conf[:server_name]}'"
    run_test_with_block "tag list #{conf[:server_name]} --format json" do |t|
      JSON.parse(t).include?(tag)
      !JSON.parse(t).include?(tag2)
    end

    self.title = TITLE + "Delete tag '#{tag}' from server '#{conf[:server_name]}'"
    run_tests [
      "tag delete #{conf[:server_name]} #{tag} -y",
      "tag delete #{conf[:server_name]} #{tag} -y"
    ]

    self.title = TITLE + "Delete server '#{conf[:server_name]}'"
    run_tests [ "server delete #{conf[:server_name]} -y" ]

  end

  def clear conf
    name = conf[:name]
    self.title = TITLE + "Delete image for #{name}"
    run_tests [ "image delete #{conf[:image]} -y" ]

    self.title = TITLE + "Check image for #{name}"
    run_test_with_block "image list #{name} --format json" do |s|
      images = JSON.parse s
      images.detect{|i| i["id"] == conf[:image]}.nil?
    end

    self.title = TITLE + "Delete #{name} filter"
    run_tests [ "filter image delete #{name} #{conf[:image]} -y" ]

    self.title = TITLE + "Check #{name} filter"
    run_test_with_block "filter image list #{name} --format json" do |i|
      images = JSON.parse(i)
      images.index(conf[:image]).nil?
    end
  end

end
