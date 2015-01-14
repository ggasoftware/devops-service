module InputUtils

  def question str
    return true if self.options[:no_ask]
    if block_given?
      yield
    end
    res = false
    #system("stty raw -echo")
    begin
      print "#{str} (y/n): "
      s = STDIN.gets.strip
      if s == "y"
        res = true
      elsif s == "n"
        res == false
      else
        raise ArgumentError.new
      end
    rescue ArgumentError
      retry
    end
    #print "#{s}\n\r"
    #system("stty -raw echo")
    res
  end

  def choose_image_cmd images, t=nil
    abort(I18n.t("handler.error.list.empty", :name => "Image")) if images.empty?
    if options[:image_id].nil?
      images[ choose_number_from_list(I18n.t("headers.image"), images, t) ]
    else
      i = images.detect { |i| i["name"] == options[:image_id]}
      abort("No such image") if i.nil?
      return i
    end
  end

  def get_comma_separated_list msg
    print msg
    STDIN.gets.strip.split(",").map{|e| e.strip}
  end

  def enter_parameter msg
    str = enter_parameter_or_empty(msg)
    raise ArgumentError.new if str.empty?
    str
  rescue ArgumentError
    retry
  end

  def enter_parameter_or_empty msg
    print msg
    return STDIN.gets.strip
  end

  def choose_number_from_list title, list, table=nil, default=nil
    i = 0
    if table.nil?
      puts I18n.t("handler.message.choose", :name => title.downcase) + "\n" + list.map{|p| i += 1; "#{i}. #{p}"}.join("\n")
    else
      puts table
    end
    begin
      print "#{title}: "
      buf = STDIN.gets.strip
      if buf.empty? and !default.nil?
        return default
      end
      i = Integer buf
    rescue ArgumentError
      retry
    end until i > 0 and i <= list.size
    return i - 1
  end

  def choose_indexes_from_list title, list, table=nil, default=nil, defindex=nil
    abort(I18n.t("handler.error.list.empty", :name => title)) if list.empty?
    ar = nil
    if table.nil?
      i = 0
      print I18n.t("handler.message.choose", :name => title.downcase) + "\n#{list.map{|p| i += 1; "#{i}. #{p}"}.join("\n")}\n"
    else
      puts table
    end
    msg = if default.nil?
      I18n.t("handler.message.choose_list", :name => title)
    else
      I18n.t("handler.message.choose_list_default", :name => title, :default => default)
    end
    begin
      ar = get_comma_separated_list(msg).map do |g|
        n = Integer g.strip
        raise ArgumentError.new(I18n.t("handler.error.number.invalid")) if n < 1 or n > list.size
        n
      end
      if ar.empty? and !default.nil?
        return [ defindex ]
      end
    rescue ArgumentError
      retry
    end
    ar.map{|i| i - 1}
  end

end
