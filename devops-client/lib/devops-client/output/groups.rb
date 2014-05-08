require "devops-client/output/base"

module Output
  module Groups
    include Base

    def table
      headers, rows = create(@list)
      create_table(headers, rows, I18n.t("output.title.group.list"), true, true)
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
      abort(I18n.t("output.not_found.group.list")) if list.nil? or list.empty?
      headers = [
                  I18n.t("output.table_header.name"),
                  I18n.t("output.table_header.protocol"),
                  I18n.t("output.table_header.from"),
                  I18n.t("output.table_header.to"),
                  I18n.t("output.table_header.cidr"),
                  I18n.t("output.table_header.description")
      ]
      rows = []
      list.each do |name, v|
        next if v.nil? or v.empty?
        p, f, t, c = [], [], [], []
        v["rules"].map do |l|
          p.push l["protocol"]
          f.push l["from"]
          t.push l["to"]
          c.push l["cidr"]
        end
        rows.push [ name, p.join("\n"), f.join("\n"), t.join("\n"), c.join("\n"), v["description"] ]
      end
      return headers, rows
    end

  end
end
