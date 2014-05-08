require "devops-client/output/base"

module Output
  module Network
    include Base

    def table
      headers, rows = create(@list, @provider)
      create_table(headers, rows, I18n.t("output.title.network.list"))
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
      headers = nil
      rows = []
      if provider == "openstack"
        abort(I18n.t("output.not_found.network.list")) if list.nil? or list.empty?
        headers = [ I18n.t("output.table_header.name"), I18n.t("output.table_header.cidr") ]
        list.each do |l|
          rows.push [ l["name"], l["cidr"] ]
        end
      elsif provider == "ec2"
        if list.nil? or list.empty?
          puts(I18n.t("output.not_found.network.list"))
          return nil, nil
        end
        headers = [
          I18n.t("output.table_header.subnet"),
          I18n.t("output.table_header.vpc_id"),
          I18n.t("output.table_header.cidr"),
          I18n.t("output.table_header.zone")
        ]
        list.each do |l|
          rows.push [ l["subnetId"], l["vpcId"], l["cidr"], l["zone"] ]
        end
      end
      return headers, rows
    end
  end
end

