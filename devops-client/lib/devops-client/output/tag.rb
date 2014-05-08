require "devops-client/output/base"

module Output
  module Tag
    include Base

    def table
      headers, rows = create(@list)
      create_table(headers, rows, I18n.t("output.title.tag.list"))
    end

    def csv
      headers, rows = create(@list)
      create_csv(headers, rows)
    end

    def json
      JSON.pretty_generate @list
    end

  private
    def create list
      abort(I18n.t("output.not_found.tag.list")) if list.empty?
      headers = [I18n.t("output.table_header.tag")]
      rows = list.map {|l| [ l ]}
      return headers, rows
    end
  end
end
