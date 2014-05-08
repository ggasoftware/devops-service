require "optparse"
require "devops-client/version"

class CommonOptions

  attr_accessor :header, :args, :default_options
  attr_writer :banner_header

  TABLE_FORMAT = "table"
  JSON_FORMAT = "json"
  CSV_FORMAT = "csv"
  OUTPUT_FROMATS = [TABLE_FORMAT, JSON_FORMAT, CSV_FORMAT]

  def initialize args, def_options
    self.args = args
    self.default_options = def_options
  end

  def self.commands *cmds
    cmds.each do |cmd|
      if cmd.is_a?(Hash)
        key = cmd.keys[0]
        cmd[key].each do |subcmd|
          create_command key.to_s, subcmd.to_s
        end
        invalid_command_method = "invalid_#{key}_command"
        banner_method = "#{key}_banner"

        define_method invalid_command_method do
          puts "#{self.header}:\n#{self.send(banner_method)}"
        end

        define_method banner_method do
          cmd[key].map{|sc| self.send("#{key}_#{sc}_banner")}.join("") + "\n"
        end
      else
        create_command cmd.to_s
      end
    end

    define_method "banners" do
      r = []
      cmds.each do |cmd|
        if cmd.is_a?(Hash)
          key = cmd.keys[0]
          cmd[key].each do |subcmd|
            r.push self.send("#{key}_#{subcmd}_banner")
          end
        else
          r.push self.send("#{cmd.to_s}_banner")
        end
      end
      r
    end

  end

  def self.create_command cmd, subcmd=nil
    name = (subcmd.nil? ? cmd : "#{cmd}_#{subcmd}")
    banner = (subcmd.nil? ? cmd : "#{cmd} #{subcmd}")

    invalid_command_method = "invalid_#{name}_command"
    banner_method = "#{name}_banner"

    define_method invalid_command_method do
      puts "#{self.header}:\n#{self.send(banner_method)}"
    end

    params_method = "#{name}_params"
    define_method banner_method do
      self.banner_header + " #{banner} #{(self.send(params_method) || []).join(" ")}\n"
    end

    options_method = "#{name}_options"
    define_method options_method do
      self.options do |opts, options|
        opts.banner << self.send(banner_method)
      end
    end

    attr_accessor params_method

  end

  def options
    o = {}
    optparse = OptionParser.new do |opts|

      opts.banner = "\n" + I18n.t("options.usage", :cmd => $0) + "\n\n" + I18n.t("options.commands") + ":\n"

      if block_given?
        opts.separator(I18n.t("options.options") + ":\n")
        yield opts, o
      end

      opts.separator("\n" + I18n.t("options.common_options") + ":\n")
      opts.on("-h", "--help", I18n.t("options.common.help")) do
        opts.banner << "\n"
        puts opts
        exit
      end

      o[:no_ask] = false
      opts.on("-y", "--assumeyes", I18n.t("options.common.confirmation")) do
        o[:no_ask] = true;
      end

      #Not used, just for banner purposes. This should be fixed when we find how to deal with options separetely
      opts.on("-c", "--config CONFIG", I18n.t("options.common.config", :file => DevopsClient.config_file)) do
        puts "Not implemented yet"
        exit
      end

      opts.on("-v", "--version", I18n.t("options.common.version")) do
        puts I18n.t("options.common.version") + ": #{DevopsClient::VERSION}"
        exit
      end

      opts.on("--host HOST", I18n.t("options.common.host", :host => default_options[:host])) do |h|
        o[:host] = h
      end

      o[:api] = default_options[:api]
      opts.on("--api VER", I18n.t("options.common.api", :api => o[:api])) do |a|
        o[:api] = a
      end

      o[:username] = default_options[:username]
      opts.on("--user USERNAME", I18n.t("options.common.username", :username => o[:username])) do |u|
        o[:username] = u.strip
        print I18n.t("handler.user.password_for", :user => o[:username])
        begin
          system("stty -echo")
          o[:password] = STDIN.gets.strip
        ensure
          system("stty echo")
        end
        puts
      end

      o[:format] = TABLE_FORMAT
      opts.on("--format FORMAT", I18n.t("options.common.format", :formats => OUTPUT_FROMATS.join("', '"), :format => TABLE_FORMAT)) do |f|
        o[:format] = f if OUTPUT_FROMATS.include?(f)
      end

      # should be handled in lib/devops-client.rb
      opts.on("", "--completion", I18n.t("options.common.completion"))

    end
    optparse.parse!(self.args)
    o
  end

  def invalid_command
    options do |opts, options|
      opts.banner << self.error_banner
      puts opts.banner
      exit(2)
    end
  end

  def error_banner
    "\t#{self.header}:\n\t#{self.banners.join("\t")}\n"
  end

  def banner_header
    "\t" + @banner_header
  end

end
