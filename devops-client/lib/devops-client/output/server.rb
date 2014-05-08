require "devops-client/output/base"

module Output
  module Server
    include Base

    def table
      title = nil
      headers, rows = if !@list.nil?
        case options[:type]
        when "chef"
          title = I18n.t("output.title.server.chef")
        when "openstack"
          title = I18n.t("output.title.server.openstack")
        when "ec2"
          title = I18n.t("output.title.server.ec2")
        else
          title = I18n.t("output.title.server.list")
        end
        create_list(@list)
      elsif !@show.nil?
        title = I18n.t("output.title.server.show", :name => @show["chef_node_name"])
        create_show(@show)
      end
      create_table headers, rows, title
    end

    def csv
      headers, rows = if !@list.nil?
        create_list(@list)
      elsif !@show.nil?
        create_show(@show)
      end
      create_csv headers, rows
    end

    def json
      JSON.pretty_generate(case ARGV[1]
      when "list"
        @list
      when "show"
        @show
      end)
    end

  private
    def create_list list
      abort(I18n.t("output.not_found.server.list")) if list.empty?
      rows, keys = [], nil
      headers = case options[:type]
      when "chef"
        keys = ["chef_node_name"]
        title = "Chef servers"
        [I18n.t("output.table_header.node_name")]
      when "openstack"
        keys = ["instance_id", "name", "public_ip", "private_ip", "keypair", "flavor", "image", "state"]
        title = "Openstack servers"
        [
          I18n.t("output.table_header.instance_id"),
          I18n.t("output.table_header.node_name"),
          I18n.t("output.table_header.public_ip"),
          I18n.t("output.table_header.private_ip"),
          I18n.t("output.table_header.keypair"),
          I18n.t("output.table_header.flavor"),
          I18n.t("output.table_header.image"),
          I18n.t("output.table_header.state")
        ]
      when "ec2"
        keys = ["instance_id", "name", "ip", "private_ip", "dns_name", "keypair", "flavor", "image", "zone", "state", "launched_at"]
        title = "Ec2 servers"
        [
          I18n.t("output.table_header.instance_id"),
          I18n.t("output.table_header.node_name"),
          I18n.t("output.table_header.public_ip"),
          I18n.t("output.table_header.private_ip"),
          I18n.t("output.table_header.dns"),
          I18n.t("output.table_header.keypair"),
          I18n.t("output.table_header.flavor"),
          I18n.t("output.table_header.image"),
          I18n.t("output.table_header.zone"),
          I18n.t("output.table_header.state"),
          I18n.t("output.table_header.created_at")
        ]
      else
        keys = ["id", "chef_node_name"]
        title = "Servers"
        [
          I18n.t("output.table_header.instance_id"),
          I18n.t("output.table_header.node_name")
        ]
      end
      list.each do |l|
        row = []
        keys.each{|k| row.push l[k]}
        rows.push row
      end
      return headers, rows
    end

    def create_show show
      rows = []
      headers = [
        I18n.t("output.table_header.instance_id"),
        I18n.t("output.table_header.node_name"),
        I18n.t("output.table_header.project"),
        I18n.t("output.table_header.deploy_env"),
        I18n.t("output.table_header.provider"),
        I18n.t("output.table_header.remote_user"),
        I18n.t("output.table_header.private_ip"),
        I18n.t("output.table_header.created_at"),
        I18n.t("output.table_header.created_by")
      ]
      keys = ["id", "chef_node_name", "project", "deploy_env", "provider", "remote_user", "private_ip", "created_at", "created_by"]
      row = []
      keys.each{|k| row.push show[k]}
      rows.push row
      return headers, rows
    end

  end
end
