require "json"
require "db/exceptions/record_not_found"
require "db/exceptions/invalid_record"
require "exceptions/dependency_error"
require "exceptions/invalid_privileges"
require "fog"
require "logger"
require "providers/provider_factory"
require "sinatra/json"
require "sinatra/base"

module Version2_0
  # Basic class for devops routes classes
  class BaseRoutes < Sinatra::Base

    helpers do
      def create_response msg, obj=nil, rstatus=200
        logger.info(msg)
        status rstatus
        obj = {} if obj.nil?
        obj[:message] = msg
        json(obj)
      end

      def halt_response msg, rstatus=400
        obj = {:message => msg}
        halt(rstatus, json(obj))
      end

      def check_privileges cmd, p
        BaseRoutes.mongo.check_user_privileges(request.env['REMOTE_USER'], cmd, p)
      end

      # Check request headers
      def check_headers *headers
        ha = (headers.empty? ? [:accept, :content_type] : headers)
        ha.each do |h|
          case h
          when :accept, "accept"
            accept_json
          when :content_type, "content_type"
            request_json
          end
        end
      end

      # Check Accept header
      #
      # Can client works with JSON?
      def accept_json
        logger.debug(request.accept)
        unless request.accept? 'application/json'
          response.headers['Accept'] = 'application/json'
          halt_response("Accept header should contains 'application/json' type", 406)
        end
      rescue NoMethodError => e
        #error in sinatra 1.4.4 (https://github.com/sinatra/sinatra/issues/844, https://github.com/sinatra/sinatra/pull/805)
        response.headers['Accept'] = 'application/json'
        halt_response("Accept header should contains 'application/json' type", 406)
      end

      # Check Content-Type header
      def request_json
        halt_response("Content-Type should be 'application/json'", 415) if request.media_type.nil? or request.media_type != 'application/json'
      end

      def check_provider provider
        list = ::Provider::ProviderFactory.providers
        halt_response("Invalid provider '#{provider}', available providers: '#{list.join("', '")}'", 404) unless list.include?(provider)
      end

      def create_object_from_json_body type=Hash, empty_body=false
        json = request.body.read.strip
        return nil if json.empty? and empty_body
        @body_json = begin
          JSON.parse(json)
        rescue => e
          logger.error e.message
          logger.debug(json)
          halt_response("Invalid JSON")
        end
        halt_response("Invalid JSON, it should be an #{type == Array ? "array" : "object"}") unless @body_json.is_a?(type)
        @body_json
      end

      def check_string val, msg, _nil=false, empty=false
        check_param val, String, msg, _nil, empty
      end

      def check_array val, msg, vals_type=String, _nil=false, empty=false
        check_param val, Array, msg, _nil, empty
        val.each {|v| halt_response(msg) unless v.is_a?(vals_type)} unless val.nil?
        val
      end

      def check_filename file_name, not_string_msg, json_resp=true
        check_string file_name, not_string_msg
        r = Regexp.new("^[\\w _\\-.]{1,255}$", Regexp::IGNORECASE)
        if r.match(file_name).nil?
          msg = "Invalid file name '#{file_name}'. Expected name with 'a'-'z', '0'-'9', ' ', '_', '-', '.' symbols with length greate then 0 and less then 256 "
          if json_resp
            halt_response(msg)
          else
            halt(400, msg)
          end
        end
        file_name
      end

      def check_param val, type, msg, _nil=false, empty=false
        if val.nil?
          if _nil
            return val
          else
            halt_response(msg)
          end
        end
        if val.is_a?(type)
          halt_response(msg) if val.empty? and !empty
          val
        else
          halt_response(msg)
        end
      end

      # Save information about requests with methods POST, PUT, DELETE
      def statistic msg=nil
        unless request.get?
          BaseRoutes.mongo.statistic request.env['REMOTE_USER'], request.path, request.request_method, @body_json, response.status
        end
      end

    end

    include Sinatra::JSON

    configure :production do
      disable :dump_errors
      disable :show_exceptions
      set :logging, Logger::INFO
    end

    configure :development do
      set :logging, Logger::DEBUG
      disable :raise_errors
#      disable :dump_errors
      set :show_exceptions, :after_handler
    end

    not_found do
      "Not found"
    end

    error RecordNotFound do
      e = env["sinatra.error"]
      logger.warn e.message
      halt_response(e.message, 404)
    end

    error InvalidRecord do
      e = env["sinatra.error"]
      logger.warn e.message
      logger.warn "Request body: #{request.body.read}"
      halt_response(e.message, 400)
    end

    error InvalidCommand do
      e = env["sinatra.error"]
      logger.warn e.message
      halt_response(e.message, 400)
    end

    error DependencyError do
      e = env["sinatra.error"]
      logger.warn e.message
      halt_response(e.message, 400)
    end

    error InvalidPrivileges do
      e = env["sinatra.error"]
      logger.warn e.message
      halt_response(e.message, 401)
    end

    error Excon::Errors::Unauthorized do
      e = env["sinatra.error"]
      resp = e.response
      ct = resp.headers["Content-Type"]
      msg = unless ct.nil?
        if ct.include?("application/json")
          json = ::Chef::JSONCompat.from_json(resp.body)
          m = "ERROR: Unauthorized (#{json['error']['code']}): #{json['error']['message']}"
          logger.error(m)
        else
        end
        m
      else
        "Unauthorized: #{e.inspect}"
      end
      halt_response(msg, 500)
    end

    error Fog::Compute::AWS::Error do
      e = env["sinatra.error"]
      logger.error e.message
      halt_response(e.message, 500)
    end

    error do
      e = env["sinatra.error"]
      logger.error e.message
      halt_response(e.message, 500)
    end

    def self.mongo
      DevopsService.mongo
    end

  end
end
