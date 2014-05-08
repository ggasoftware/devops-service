require "httpclient"
require "exceptions/devops_exception"
require "exceptions/not_found"
require "exceptions/invalid_query"
require "devops-client/options/common_options"
require "uri"
require "json"
require "devops-client/i18n"

class Handler

  attr_reader :options
  attr_writer :host
  attr_accessor :auth

  def host
    "http://#{@host}"
  end

  #TODO: only basic auth now
  def username
    self.options[:username] || self.auth[:username]
  end

  def password
    self.options[:password] || self.auth[:password]
  end

  def options= o
    self.host = o.delete(:host) if o.has_key? :host
    @options = o
  end

  def get_chunk path, params={}
    submit do |http|
      http.get(create_url(path), convert_params(params)) do |chunk|
        puts chunk
      end
    end
    ""
  end

  def get path, params={}
    get_with_headers path, params, self.headers("Content-Type")
  end

  def get_with_headers path, params={}, headers={}
    submit do |http|
      http.get(create_url(path), convert_params(params), headers)
    end
  end

  def post path, params={}
    self.post_body(path, params.to_json)
  end

  def post_body path, body
    post_body_with_headers path, body, self.headers
  end

  def post_chunk_body path, body, json=true
    h = (json ? self.headers : self.headers("Content-Type", "Accept"))
    submit do |http|
      buf = ""
      resp = http.post(create_url(path), body, h) do |chunk|
        puts chunk
        buf = chunk
      end
      if resp.ok?
        status = check_status(buf)
        exit(status) unless status == 0
      end
      resp
    end
    ""
  end

  def post_chunk path, params={}
    self.post_chunk_body path, params.to_json
  end

  def post_body_with_headers path, body='', headers={}
    submit do |http|
      http.post(create_url(path), body, headers)
    end
  end

  def delete path, params={}
    delete_body path, params.to_json
  end

  def delete_body path, body
    submit do |http|
      http.delete(create_url(path), body, self.headers)
    end
  end

  def put path, params={}
    put_body path, params.to_json
  end

  def put_body path, body
    submit do |http|
      http.put(create_url(path), body, self.headers)
    end
  end

protected
  def puts_warn msg
    puts "\e[33m#{msg}\e[0m"
  end

  def puts_error msg
    puts "\e[31m#{msg}\e[0m"
  end

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

  def output
    case self.options[:format]
    when CommonOptions::TABLE_FORMAT
      table
    when CommonOptions::JSON_FORMAT
      json
    when CommonOptions::CSV_FORMAT
      csv
    end
  end

  def update_object_from_file object_class, object_id, file
    unless File.exists?(file)
      @options_parser.invalid_update_command
      abort I18n.t("handler.error.file.not_exist", :file => file)
    end
    update_object_from_json object_class, object_id, File.read(file)
  end

  def update_object_from_json object_class, object_id, json
    put_body "/#{object_class}/#{object_id}", json
  rescue NotFound => e
    post_body "/#{object_class}", json
  end

  def create_url path
    URI.join(self.host, self.options[:api] + path).to_s
  end

  def submit
    http = HTTPClient.new
    http.receive_timeout = 0
    http.send_timeout = 0
    http.set_auth(nil, self.username, self.password)
    res = yield http
    if res.ok?
      return (res.contenttype.include?("application/json") ? JSON.parse(res.body) : res.body)
    end
    case res.status
    when 404
      raise NotFound.new(extract_message(res))
    when 400
      raise InvalidQuery.new(extract_message(res))
    when 401
      e = extract_message(res)
      e = I18n.t("handler.error.unauthorized") if (e.nil? or e.strip.empty?)
      raise DevopsException.new(e)
    else
      raise DevopsException.new(extract_message(res))
    end
  end

  def extract_message result
    return nil if result.body.nil?
    result.contenttype.include?("application/json") ? JSON.parse(result.body)["message"] : result.body
  end

  def convert_params params
    params_filter(params.select{|k,v| k != :cmd and !v.nil?}).join("&")
  end

  def params_filter params
    r = []
    return params if params.kind_of?(String)
    params.each do |k,v|
      key = k.to_s
      if v.kind_of?(Array)
        v.each do |val|
          r.push "#{key}[]=#{val}"
        end
      elsif v.kind_of?(Hash)
        buf = {}
        v.each do |k1,v1|
          buf["#{key}[#{k1}]"] = v1
        end
        r = r + params_filter(buf)
      else
        r.push "#{key}=#{v}"
      end
    end
    r
  end

  def inspect_parameters names, *args
    names.each_with_index do |name, i|
      next if name.start_with? "[" and name.end_with? "]"
      if args[i].nil? or args[i].empty?
        return "\n" + I18n.t("handler.error.parameter.undefined", :name => name)
      end
    end
    nil
  end

  def headers *exclude
    h = {
      "Accept" => "application/json",
      "Content-Type" => "application/json; charset=UTF-8"
    }

    h["Accept-Language"] = I18n.lang
    exclude.each do |key|
      h.delete(key)
    end
    h
  end

  def check_status status
    r = status.scan(/--\sStatus:\s([0-9]{1,5})\s--/i)[0]
    if r.nil?
      puts "WARN: status undefined"
      -1
    else
      r[0].to_i
    end
  end

end
