require "devops-client/output/base"

module Output
  module Provider
    include Base

    def table
      headers, rows = create(@list)
      create_table(headers, rows, I18n.t("output.title.provider.list"))
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
      abort(I18n.t("output.not_found.provider.list")) if list.empty?
      headers = [ I18n.t("output.table_header.provider") ]
      rows = []
      list.each do |l|
        rows.push [ l ]
      end
      return headers, rows
    end
  end
end
