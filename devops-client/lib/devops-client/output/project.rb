require "devops-client/output/base"

module Output
  module Project
    include Base

    NODE_HEADER = "Node number"
    SUBPROJECT_HEADER = "Subproject"

    def table
      title, = nil
      with_num, with_separator = true, false
      headers, rows = if !@list.nil?
        title = I18n.t("output.title.project.list")
        create_list(@list)
      elsif !@show.nil?
        title = I18n.t("output.title.project.show", :name => @show["name"])
        with_num = false
        with_separator = true
        create_show(@show)
      elsif !@servers.nil?
        title = ARGV[2]
        title += " " + ARGV[3] unless ARGV[3].nil?
        title = I18n.t("output.title.project.servers", :title => title)
        create_servers(@servers)
      elsif !@test.nil?
        with_num = false
        title = I18n.t("output.title.project.test", :project => ARGV[2], :env => ARGV[3])
        create_test(@test)
      end
      create_table(headers, rows, title, with_num, with_separator)
    end

    def csv
      with_num = true
      headers, rows = if !@list.nil?
        create_list(@list)
      elsif !@show.nil?
        with_num = false
        create_show(@show)
      elsif !@servers.nil?
        create_servers(@servers)
      elsif !@test.nil?
        with_num = false
        create_test(@test)
      end
      create_csv(headers, rows, with_num)
    end

    def json
      JSON.pretty_generate(case ARGV[1]
      when "list"
        @list.map {|l| l["name"]}
      when "show"
        @show
      when "servers"
        @servers
      when "test"
        @test
      end)
    end

  private
    def create_list list
      abort(I18n.t("output.not_found.project.list")) if list.empty?
      rows = list.map {|l| [l["name"]]}
      headers = [ I18n.t("output.table_header.id") ]
      return headers, rows
    end

    def create_show show
      rows = []
      headers = if show["type"] == "multi"
        show["deploy_envs"].each do |de|
          subprojects = []
          nodes = []
          de["servers"].each do |s|
            s["subprojects"].each do |sp|
              subprojects.push "#{sp["name"]} - #{sp["env"]}"
              nodes.push sp["node"]
            end
          end
          rows.push [ de["identifier"], subprojects.join("\n"), nodes.join("\n"), de["users"].join("\n") ]
        end
        [
          I18n.t("output.table_header.deploy_env"),
          I18n.t("output.table_header.subproject") + " - " + I18n.t("output.table_header.deploy_env"),
          I18n.t("output.table_header.node_number"),
          I18n.t("output.table_header.users")
        ]
      else
        show["deploy_envs"].each do |de|
          rows.push [ show["name"], de["identifier"], de["image"], de["flavor"], de["run_list"].join("\n"), de["groups"].join("\n"), de["subnets"].join("\n"), de["users"].join("\n") ]
        end
        [
          I18n.t("output.table_header.id"),
          I18n.t("output.table_header.deploy_env"),
          I18n.t("output.table_header.image_id"),
          I18n.t("output.table_header.flavor"),
          I18n.t("output.table_header.run_list"),
          I18n.t("output.table_header.groups"),
          I18n.t("output.table_header.subnets"),
          I18n.t("output.table_header.users")
        ]
      end
      return headers, rows
    end

    def create_servers servers
      abort(I18n.t("output.not_found.project.servers")) if servers.empty?
      rows = []
      servers.each do |s|
        rows.push [ s["project"], s["deploy_env"], s["chef_node_name"], s["remote_user"], s["provider"], s["id"] ]
      end
      headers = [
        I18n.t("output.table_header.id"),
        I18n.t("output.table_header.deploy_env"),
        I18n.t("output.table_header.node_name"),
        I18n.t("output.table_header.remote_user"),
        I18n.t("output.table_header.provider"),
        I18n.t("output.table_header.instance_id")
      ]
      return headers, rows
    end

    def create_test test
      rows = []
      headers = [
        I18n.t("output.table_header.server"),
        I18n.t("output.table_header.node_name"),
        I18n.t("output.table_header.creation"),
        I18n.t("output.table_header.bootstrap"),
        I18n.t("output.table_header.deletion")
      ]
      test["servers"].each do |s|
        rows.push [ s["id"],
                    s["chef_node_name"],
                    "#{s["create"]["status"]}\n#{s["create"]["time"]}",
                    "#{s["bootstrap"]["status"]}\n#{s["bootstrap"]["time"]}",
                    "#{s["delete"]["status"]}\n#{s["delete"]["time"]}" ]
      end
      return headers, rows
    end

  end
end
