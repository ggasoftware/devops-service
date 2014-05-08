require "devops-client/output/base"

module Output
  module Flavors
    include Base

    def table
      headers, rows = create(@list, @provider)
      create_table(headers, rows, I18n.t("output.title.flavor.list"))
    end

    def csv
      headers, rows = create(@list, @provider)
      create_csv(headers, rows)
    end

    def json
      JSON.pretty_generate @list
    end

  private
    def create list, provider
      abort(I18n.t("output.not_found.flavor.list")) if list.nil? or list.empty?
      headers = nil
      rows = []
      if provider == "openstack"
        headers = [
                    I18n.t("output.table_header.id"),
                    I18n.t("output.table_header.virtual_cpus"),
                    I18n.t("output.table_header.disk"),
                    I18n.t("output.table_header.ram")
        ]
        list.each do |l|
          rows << [ l["id"], l["v_cpus"], l["disk"], l["ram"] ]
        end
      elsif provider == "ec2"
        headers = [
                    I18n.t("output.table_header.name"),
                    I18n.t("output.table_header.id"),
                    I18n.t("output.table_header.virtual_cpus"),
                    I18n.t("output.table_header.disk"),
                    I18n.t("output.table_header.ram")
        ]
        list.each do |l|
          rows << [ l["name"], l["id"], l["cores"], l["disk"], l["ram"] ]
        end
      end
      return headers, rows
    end
  end
end
