require "devops-client/output/base"

module Output
  module Image
    include Base

    def table
      title, headers, rows = nil, nil, nil
      with_num = if !@list.nil?
        title = I18n.t("output.title.image.list")
        headers, rows = create_list(@list, @provider)
        true
      elsif !@show.nil?
        title = I18n.t("output.title.image.show", :id => @show["id"])
        headers, rows = create_show @show
        false
      end
      create_table headers, rows, title, with_num
    end

    def csv
      title, headers, rows = nil, nil, nil
      with_num = if !@list.nil?
        headers, rows = create_list(@list, @provider)
        true
      elsif !@show.nil?
        headers, rows = create_show @show
        false
      end
      create_csv headers, rows, with_num
    end

    def json
      JSON.pretty_generate( case ARGV[1]
      when "list"
        @list
      when "show"
        @show
      end)
    end

  private
    def create_list list, provider
      abort(I18n.t("output.not_found.image.list")) if list.empty?
      rows = []
      headers = if provider
        list.each {|l| rows.push [ l["name"], l["id"], l["status"] ]}
        [
          I18n.t("output.table_header.name"),
          I18n.t("output.table_header.id"),
          I18n.t("output.table_header.status")
        ]
      else
        list.each {|l| rows.push  [ l["id"], l["name"], l["bootstrap_template"], l["remote_user"], l["provider"] ] }
        [
          I18n.t("output.table_header.id"),
          I18n.t("output.table_header.name"),
          I18n.t("output.table_header.template"),
          I18n.t("output.table_header.remote_user"),
          I18n.t("output.table_header.provider")
        ]
      end
      return headers, rows
    end

    def create_show show
      rows = [ [ show["id"], show["name"], show["bootstrap_template"], show["remote_user"], show["provider"] ] ]
      headers = [
        I18n.t("output.table_header.id"),
        I18n.t("output.table_header.name"),
        I18n.t("output.table_header.template"),
        I18n.t("output.table_header.remote_user"),
        I18n.t("output.table_header.provider")
      ]
      return headers, rows
    end

  end
end
