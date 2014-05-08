require "terminal-table"
require "csv"
require "json"

module Output
  module Base

    def create_table headers, rows, title=nil, with_num=true, separator=false
      return nil if headers.nil? or rows.nil?
      if with_num
        headers.unshift(I18n.t("output.table_header.number"))
        rows.each_with_index {|row, i| row.unshift(i + 1)}
      end
      table = Terminal::Table.new do |t|
        titles = ["#{I18n.t("output.table_header.api_version")}: #{self.options[:api]}",
                   "#{title}"
                 ]
        t.title = titles.join( "\n" )
        t.headings = headers
        t.add_row rows[0]
        rows[1..-1].each do |r|
          t.add_separator if separator
          t.add_row r
        end
      end
      table
    end

    def create_csv headers, rows, with_num=true, separator=":"
      if with_num
        headers.unshift(I18n.t("output.table_header.number"))
        rows.each_with_index {|row, i| row.unshift(i + 1)}
      end
      c = CSV.new("", {col_sep: separator, headers: true})
      c << headers
      rows.each{|r| c << r}
      c.string
    end

  end
end
