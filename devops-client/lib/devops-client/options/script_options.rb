require "devops-client/options/common_options"

class ScriptOptions < CommonOptions

  commands :list, :add, :delete, :run, :command

  def initialize args, def_options
    super(args, def_options)
    self.header = I18n.t("headers.script")
    self.banner_header = "script"
    sname = "SCRIPT_NAME"
    self.add_params = [sname, "FILE"]
    self.delete_params = [sname]
    self.run_params = [sname, "NODE_NAME", "[NODE_NAME ...]"]
    self.command_params = ["NODE_NAME", "'sh command'"]
  end

  def run_options
    options do |opts, options|
      opts.banner << self.delete_banner
      opts.on("--params PARAMS", I18n.t("options.script.run.params")) do |p|
        options[:params] = p.split(",")
      end
    end
  end

end
