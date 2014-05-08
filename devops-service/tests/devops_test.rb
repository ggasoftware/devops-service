require "json"
require "httpclient"
require "./config"

class DevopsTest

  attr_accessor :password, :response, :host
  attr_reader :username

  def initialize
    puts_head " #{self.title} ".center(80, "=")
    self.host = HOST
#    self.username = USERNAME
#    self.password = PASSWORD
  end

  def submit
    http = HTTPClient.new
    http.receive_timeout = 0
    http.send_timeout = 0
    http.set_auth(nil, self.username, self.password)
    self.response = yield http
    self.response.body
  end

  def username= user
    @username = user
    self.password = if user == ROOTUSER
      ROOTPASS
    else
      PASSWORD
    end
    puts_warn(" - User: " + @username + " - ")
  end

  def all_privileges
    self.username = USERNAME
  end

  def read_only_privileges
    self.username = USERNAME + "_r"
  end

  def write_only_privileges
    self.username = USERNAME + "_w"
  end

  def empty_privileges
    self.username = USERNAME + "_"
  end

  def get path, params={}, headers={}
    url = create_url(path)
    m = "GET #{url.path.ljust(30)}"
    m += " HEADERS(#{headers.map{|k,v| "#{k}: #{v}" }.join(", ")})" unless headers.empty?
    print m.ljust(99)
    submit do |http|
      http.get(url, convert_params(params), headers)
    end
  end

  def post path, params={}, headers={}
    url = create_url(path)
    m = "POST #{url.path.ljust(30)}"
    m += " HEADERS(#{headers.map{|k,v| "#{k}: #{v}" }.join(", ")})" unless headers.empty?
    print m.ljust(99)
    submit do |http|
      http.post(url, params.to_json, headers)
    end
  end

  def send_post path, params={}, headers={}, status=200
    self.post path, params, headers
    self.check_status status
    self.check_json_response
  end

  def delete path, params={}, headers={}
    url = create_url(path)
    m = "DELETE #{url.path.ljust(30)}"
    m += " HEADERS(#{headers.map{|k,v| "#{k}: #{v}" }.join(", ")})" unless headers.empty?
    print m.ljust(99)
    b = (params.nil? ? nil : params.to_json)
    submit do |http|
      http.delete(url, b, headers)
    end
  end

  def send_delete path, params={}, headers={}, status=200
    self.delete path, params, headers
    self.check_status status
    self.check_json_response
  end

  def post_chunk path, params={}, headers={}
    url = create_url(path)
    m = "POST #{url.path.ljust(30)}"
    m += " HEADERS(#{headers.map{|k,v| "#{k}: #{v}" }.join(", ")})" unless headers.empty?
    print m.ljust(99)
    submit do |http|
      http.post(url, params.to_json, headers) do |c|
      end
    end
  end

  def send_put path, params={}, headers={}, status=200
    self.put path, params, headers
    self.check_status status
    self.check_json_response
  end

  def put path, params={}, headers={}
    url = create_url(path)
    m = "PUT #{url.path.ljust(30)}"
    m += " HEADERS(#{headers.map{|k,v| "#{k}: #{v}" }.join(", ")})" unless headers.empty?
    print m.ljust(99)
    submit do |http|
      http.put(url, params.to_json, headers)
    end
  end

  def check_status code
    if self.response.status == code
      self.puts_success
    else
      self.puts_error "STATUS: #{self.response.status}, but checked with '#{code}'"
    end
  end

  def check_json_response
    return if self.response.status == 404
    j = begin
      JSON.parse(self.response.body)
    rescue
      self.puts_error "Invalid json, response body: '#{self.response.body}'"
    end
    self.puts_error "Response in Json format, but without parameter 'message'" unless j.key?("message")
  end

  def check_type type
    res = self.response
    if res.ok?
      case type
      when :json
        puts_error("Invalid content-type '#{res.contenttype}'") unless res.contenttype.include?("application/json")
      else
        puts_error("Unknown type '#{type}'")
      end
    end
  end

  def puts_head str
    puts "\e[31m#{str}\e[0m"
  end

  def puts_error str
    puts "\t\e[31m#{str}\e[0m"
    raise str
  end

  def puts_warn str
    puts "\t\e[33m#{str}\e[0m"
  end

  def puts_success str="success"
    puts "\t\e[32m#{str}\e[0m"
  end

private
  def create_url path
    path = "/" + path unless path.start_with? "/"
    URI.join("http://" + self.host, "v2.0" + path)
  end

  def convert_params params
    return nil if params.nil? or params.empty?
    params_filter(params).join("&")
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

end
