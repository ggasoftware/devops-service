require "json"
require "db/exceptions/invalid_record"
require "db/mongo/models/key"
require "fileutils"

module Version2_0
  class KeyRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Key routes initialized"
    end

    before %r{\A/key(/[\w]+)?\z} do
      if request.delete?
        check_headers :accept
      else
        check_headers :accept, :content_type
      end
      check_privileges("key", "w")
    end

    after %r{\A/key(/[\w]+)?\z} do
      statistic
    end

    # Get list of available ssh keys
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* : array of strings
    #   [
    #     {
    #       "scope": "system", -> 'system' - key was added by server, 'user' - key was added by user
    #       "id": "devops"
    #     }
    #   ]
    get "/keys" do
      check_headers :accept
      check_privileges("key", "r")
      keys = BaseRoutes.mongo.keys.map {|i| i.to_hash}
      keys.each {|k| k.delete("path")}   # We should not return path to the key
      json keys
    end

    # Create ssh key on devops server
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "file_name": "key file name",
    #       "key_name": "key name",
    #       "content": "key content"
    #     }
    #
    # * *Returns* :
    #   201 - Created
    post "/key" do
      key = create_object_from_json_body
      fname = check_filename(key["file_name"], "Parameter 'file_name' must be a not empty string")
      kname = check_string(key["key_name"], "Parameter 'key_name' should be a not empty string")
      content = check_string(key["content"], "Parameter 'content' should be a not empty string")
      file_name = File.join(DevopsService.config[:keys_dir], fname)
      halt(400, "File '#{fname}' already exist") if File.exists?(file_name)
      File.open(file_name, "w") do |f|
        f.write(content)
        f.chmod(0400)
      end

      key = Key.new({"path" => file_name, "id" => kname})
      BaseRoutes.mongo.key_insert key
      create_response("Created", nil, 201)
    end

    # Delete ssh key from devops server
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/key/:key" do
      servers = BaseRoutes.mongo.servers_by_key params[:key]
      unless servers.empty?
        s_str = servers.map{|s| s.id}.join(", ")
        raise DependencyError.new "Deleting is forbidden: Key is used in servers: #{s_str}"
      end

      k = BaseRoutes.mongo.key params[:key]
      begin
        FileUtils.rm(k.path)
      rescue
        logger.error "Missing key file for #{params[:key]} - #{k.filename}"
      end
      r = BaseRoutes.mongo.key_delete params[:key]
      return [500, r["err"].inspect] unless r["err"].nil?
      create_response("Key '#{params[:key]}' removed")
    end

  end
end
