module BootstrapTemplatesCommands

  def get_templates
    res = []
    Dir.foreach("#{ENV["HOME"]}/.chef/bootstrap/") {|f| res.push(f[0..-5]) if f.end_with?(".erb")} if File.exists? "#{ENV["HOME"]}/.chef/bootstrap/"
    res
  end

end
