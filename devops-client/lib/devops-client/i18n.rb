module I18n

  @@lang = {}

  def self.language= locale
    spec = Gem::Specification.find_by_name(DevopsClient::NAME)
    gem_root = spec.gem_dir
    path = File.join(gem_root, "locales", "#{locale}.yml")
    raise ArgumentError.new("Invalid locale '#{locale}'") unless File.exist?(path)
    require 'yaml'
    begin
      @@lang = YAML.load_file(path)[locale]
    rescue
      raise ArgumentError.new("Invalid file '#{locale}.yml'")
    end
  end

  def self.t label, options={}
    path = label.split(".")
    buf = @@lang
    begin
      path.each do |index|
        buf = buf[index]
      end
      raise ArgumentError unless buf.is_a?(String)
    rescue
      return "Translation missing"
    end
    options.each do |k,v|
      buf.gsub!("%{#{k.to_s}}", v.to_s)
    end
    buf
  end

  def self.locales
    spec = Gem::Specification.find_by_name(DevopsClient::NAME)
    gem_root = spec.gem_dir
    path = File.join(gem_root, "locales")
    locales = []
    Dir.foreach(path) do |item|
      next if item.start_with? '.'
      if item.end_with? ".yml"
        locales.push item.split(".")[0]
      end
    end
    locales
  end

  def self.lang
    @@lang
  end

end
