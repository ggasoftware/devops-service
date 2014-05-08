require "devops-client/output/base"

module Output
  module User
    include Base

    def table
      title, headers = nil, nil
      rows, with_num = create_subheader, false
      rows += create_rows(@list)
      headers = [
        "",
        "",
        "",
        {:value => I18n.t("output.table_header.privileges"), :colspan => 12, :alignment => :center }
      ]

      create_table headers, rows, I18n.t("output.title.user.list"), with_num, true
    end

    def csv
      rows = create_rows(@list)
      headers = create_subheader
      create_csv headers, rows
    end

    def json
      JSON.pretty_generate( case ARGV[1]
      when "list"
        @list
      end)
    end

  private
    def create_subheader
      [ [
        I18n.t("output.table_header.number"),
        I18n.t("output.table_header.id"),
        I18n.t("output.table_header.email"),
        I18n.t("output.table_header.image"),
        I18n.t("output.table_header.key"),
        I18n.t("output.table_header.project"),
        I18n.t("output.table_header.server"),
        I18n.t("output.table_header.users"),
        I18n.t("output.table_header.script"),
        I18n.t("output.table_header.filter"),
        I18n.t("output.table_header.flavor"),
        I18n.t("output.table_header.group"),
        I18n.t("output.table_header.network"),
        I18n.t("output.table_header.provider"),
        I18n.t("output.table_header.templates")
      ] ]
    end

    def create_rows list
      abort(I18n.t("output.not_found.user.list")) if list.nil? or list.empty?
      rows = []
      list.each_with_index do |l, i|
        next if l["privileges"].nil?

        flavor = "#{l["privileges"]["flavor"]}"
        group = "#{l["privileges"]["group"]}"
        image = "#{l["privileges"]["image"]}"
        project = "#{l["privileges"]["project"]}"
        server = "#{l["privileges"]["server"]}"
        key = "#{l["privileges"]["key"]}"
        user = "#{l["privileges"]["user"]}"
        filter = "#{l["privileges"]["filter"]}"
        network = "#{l["privileges"]["network"]}"
        provider = "#{l["privileges"]["provider"]}"
        script = "#{l["privileges"]["script"]}"
        templates = "#{l["privileges"]["templates"]}"

        rows.push  [ (i + 1).to_s, l["id"], l["email"], image, key, project, server, user, script, filter, flavor, group, network, provider, templates]
      end
      rows
    end
  end
end
