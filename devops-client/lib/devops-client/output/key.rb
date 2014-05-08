require "devops-client/output/base"

module Output
  module Key
    include Base

    def table
      title = I18n.t("output.title.key.list")
      headers, rows = create(@list)
      create_table headers, rows, title
    end

    def csv
      headers, rows = create(@list)
      create_csv headers, rows
    end

    def json
      JSON.pretty_generate( case ARGV[1]
      when "list"
        @list
      end)
    end

  private
    def create list
      abort(I18n.t("output.not_found.key.list")) if list.nil? or list.empty?
      rows = []
      list.each {|l| rows.push  [ l["id"], l["scope"] ] }
      return [ I18n.t("output.table_header.id"), I18n.t("output.table_header.scope") ], rows
    end
  end
end
