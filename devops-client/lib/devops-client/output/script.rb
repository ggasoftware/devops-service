require "devops-client/output/base"

module Output
  module Script
    include Base

    def table
      headers, rows = create(@list)
      create_table(headers, rows, I18n.t("output.title.script.list"))
    end

    def csv
      headers, rows = create(@list)
      create_csv(headers, rows)
    end

    def json
      JSON.pretty_generate( case ARGV[1]
      when "list"
        @list
      end)
    end

  private
    def create list
      rows = []
      abort(I18n.t("output.not_found.script.list")) if list.nil? or list.empty?
      list.each do |l|
        rows.push [ l ]
      end
      headers = [I18n.t("output.table_header.name")]
      return headers, rows
    end
  end
end
