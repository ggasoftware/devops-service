require "devops-client/handler/handler"
require "devops-client/options/filter_options"
require "json"
require "devops-client/output/filters"

class Filter < Handler

  attr_accessor :def_options

  def initialize(host, def_options)
    self.host = host
    self.def_options = def_options
    @options_parser = FilterOptions.new(ARGV, def_options)
  end

  include Output::Filters

  def handle
    case ARGV[1]
    when "image"
      provider = ARGV[3]
      case ARGV[2]
      when "list"
        self.options = @options_parser.image_list_options
        check_provider provider
        @list = get("/filter/#{provider}/images")
        output
      when "add"
        self.options = @options_parser.image_add_options
        check_provider provider
        @list = put_body("/filter/#{provider}/image", get_images(ARGV).to_json)
        @list = @list["images"] unless @list.nil?
        output
      when "delete"
        self.options = @options_parser.image_delete_options
        check_provider provider
        images = get_images(ARGV)
        if question(I18n.t("handler.filter.question.delete", :name => images.join("', '")))
          @list = delete_body("/filter/#{provider}/image", images.to_json)
          @list = @list["images"] unless @list.nil?
          output
        end
      else
        @options_parser.invalid_image_command
        abort("Invalid image parameter: #{ARGV[2]}, it should be 'add' or 'delete' or 'list'")
      end
    else
      @options_parser.invalid_command
    end
  end

  def check_provider provider
    if provider != "ec2" and provider != "openstack"
      @options_parser.invalid_image_command
      abort("Invalid image parameter: provider '#{provider}', it should be 'ec2' or 'openstack'")
    end
  end

  def get_images args
    images = args[4..-1]
    if images.empty?
      @options_parser.invalid_image_command
      abort("Images list is empty")
    end
    images
  end

end
