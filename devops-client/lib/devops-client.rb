require 'devops-client/name'
require "devops-client/version"
require "devops-client/handler/handler_factory"
require "exceptions/not_found"
require "exceptions/invalid_query"
require "exceptions/devops_exception"
require "optparse"
require "devops-client/i18n"

module DevopsClient

  DEVOPS_HOME = "#{ENV["HOME"]}/.devops/"
  # properties file key=value
  @@config_file = File.join(DEVOPS_HOME, "devops-client.conf")
  #CONFIG_FILE="#{ENV["HOME"]}/.devops/devops-client.conf"

  def self.config_file
    @@config_file
  end

  def self.run

    DevopsClient::get_config_file_option
    config = DevopsClient::read_config(@@config_file)

    I18n.language=(config[:locale] || "en")

    if ARGV.include? "--completion"
      init_completion
      exit
    end

    if config[:host].nil?
      abort(I18n.t("config.invalid.host"), :file => @@config_file)
    end
    [:api, :username, :password].each do |key|
      if config[key].nil? or config[key].empty?
        abort(I18n.t("config.invalid.empty", :file => @@config_file, :key => key))
      end
    end
    configure_proxy config

    host = config[:host]
    default = {:username => config[:username], :api => config[:api], :host => config[:host], :prefix => ((config[:prefix].nil? or config[:prefix].empty?) ? nil : config[:prefix])}
    auth = {:username => config[:username], :password => config[:password], :type => "basic"}

    handler = HandlerFactory.create(ARGV[0], host, auth, default)
    result = handler.handle
    if result.is_a?(Hash)
      puts result["message"]
    else
      puts result
    end
  rescue OptionParser::InvalidOption => e
    puts e.message
    exit(11)
  rescue NotFound => e
    puts "Not found: #{e.message}"
    exit(12)
  rescue InvalidQuery => e
    puts "Invalid query: #{e.message}"
    exit(13)
  rescue DevopsException => e
    puts I18n.t("log.error", :msg => e.message)
    exit(14)
  rescue => e
    puts I18n.t("log.error", :msg => e.message)
    raise e
  rescue Interrupt
    puts "\nInterrupted"
    exit(15)
  end

  PROXY_TYPE_NONE = "none"
  PROXY_TYPE_SYSTEM = "system"
  PROXY_TYPE_CUSTOM = "custom"
  PROXY_TYPES = [PROXY_TYPE_NONE, PROXY_TYPE_SYSTEM, PROXY_TYPE_CUSTOM]
  PROXY_ENV = ["all_proxy", "ALL_PROXY", "proxy", "PROXY", "http_proxy", "HTTP_PROXY", "https_proxy", "HTTPS_PROXY"]
  def self.configure_proxy config
    config[:proxy_type] = PROXY_TYPE_NONE if config[:proxy_type].nil?
    case config[:proxy_type]
    when PROXY_TYPE_SYSTEM
      nil
    when PROXY_TYPE_NONE
      PROXY_ENV.each {|k| ENV[k] = nil}
    when PROXY_TYPE_CUSTOM
      ["http_proxy", "HTTP_PROXY"].each {|k| ENV[k] = config[:http_proxy]}
    else
      abort(I18n.t("config.invalid.proxy_type", :file => @@config_file, :values => PROXY_TYPES.join(", ")))
    end
  end

  def self.read_config file
    config = {}
    if File.exists? file
      File.open(file, "r") do |f|
        f.each_line do |line|
          line.strip!
          next if line.empty? or line.start_with?("#")
          buf = line.split("=")
          config[buf[0].strip.to_sym] = buf[1].strip if !(buf[1].nil? or buf[1].empty?)
        end
      end
    else
      config = set_default_config(file)
    end
    config
  end

  def self.set_default_config file
    locales = I18n.locales
    config = {:api => "v2.0", :locale => "en"}
    I18n.language = config[:locale]
    puts I18n.t("log.warn", :msg => I18n.t("config.not_exist", :file => file))
    config[:locale] = begin
      l = get_config_parameter(I18n.t("config.property.lang", :langs => locales.join(", ")), config[:locale])
      raise ArgumentError unless locales.include?(l)
      I18n.language = l
      l
    rescue ArgumentError
      retry
    end
    config[:host] = get_config_parameter(I18n.t("config.property.host"))
    config[:prefix] = get_config_parameter(I18n.t("config.property.prefix"))
    config[:api] = get_config_parameter(I18n.t("config.property.api"), config[:api])
    config[:username] = get_config_parameter(I18n.t("config.property.username"))
    config[:password] = get_config_parameter(I18n.t("config.property.password"))
    begin
      config[:proxy_type] = get_config_parameter(I18n.t("config.property.proxy_type"))
      raise ArgumentError unless PROXY_TYPES.include?(config[:proxy_type])
    rescue ArgumentError
      retry
    end
    if config[:proxy_type] == PROXY_TYPE_CUSTOM
      config[:http_proxy] = get_config_parameter(I18n.t("config.property.http_proxy"))
    end

    dir = File.dirname(@@config_file)
    require "fileutils"
    FileUtils.mkdir(dir) unless File.exists? dir
    File.open(file, "w") do |f|
      config.each do |k,v|
        f.puts "#{k.to_s}=#{v}"
      end
    end
    puts I18n.t("config.created", :file => file)
    config
  end

  def self.get_config_parameter msg, default=nil
    print(msg + (default.nil? ? ": " : "(#{default}): "))
    p = STDIN.gets.strip
    return (p.empty? ? default : p)
  end

  def self.get_config_file_option
    ARGV.each_index do |i|
      if ARGV[i] == "-c" or ARGV[i] == "--config"
        if ARGV[i+1] !~ /^-.*/ and ARGV[i+i] !~ /^--.*/
          @@config_file = ARGV[i+1]
          ARGV.delete_at(i)
          ARGV.delete_at(i)
        else
          puts I18n.t("log.error", :msg => I18n.t("config.invalid.parameter"))
          exit(3)
        end
      end
    end
  end

  def self.init_completion
    spec = Gem::Specification.find_by_name(DevopsClient::NAME)
    gem_root = spec.gem_dir
    path = File.join(gem_root, "completion", "devops_complete.sh")
    require "fileutils"
    FileUtils.cp(path, DEVOPS_HOME)
    file = File.join(DEVOPS_HOME, "devops_complete.sh")
    puts I18n.t("completion.message", :file => file)
    puts "\n\e[32m#{I18n.t("completion.put", :file => file)}\e[0m"
  end

end
