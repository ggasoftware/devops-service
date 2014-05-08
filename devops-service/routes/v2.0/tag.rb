require "commands/knife_commands"

module Version2_0
  class TagRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Tag routes initialized"
    end

    before "/tags/:node_name" do
      if request.get?
        check_headers :accept
        check_privileges("server", "r")
      else
        check_headers :accept, :content_type
        check_privileges("server", "w")
        @tags = create_object_from_json_body(Array)
        check_array(@tags, "Request body should be a not empty array of strings")
      end
      server = BaseRoutes.mongo.server_by_chef_node_name(params[:node_name])
      halt_response("No servers found for name '#{params[:node_name]}'", 404) if server.nil?
      @chef_node_name = server.chef_node_name
    end

    after "/tags/:node_name" do
      statistic
    end

    # Get tags list for :node_name
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   [
    #     "tag_1"
    #   ]
    get "/tags/:node_name" do
      json(KnifeCommands.tags_list(@chef_node_name))
    end

    # Set tags list to :node_name
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #   [
    #     "tag_1"
    #   ]
    #
    # * *Returns* :
    #   200
    post "/tags/:node_name" do
      tagsStr = @tags.join(" ")
      cmd = KnifeCommands.tags_create(@chef_node_name, tagsStr)
      halt_response("Error: Cannot add tags #{tagsStr} to server #{@chef_node_name}", 500) unless cmd[1]
      create_response("Set tags for #{@chef_node_name}: #{tagsStr}")
    end

    # Delete tags from :node_name
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #   [
    #     "tag_1"
    #   ]
    #
    # * *Returns* :
    #   200
    delete "/tags/:node_name" do
      tagsStr = @tags.join(" ")
      cmd = KnifeCommands.tags_delete(@chef_node_name, tagsStr)
      halt_response("Cannot delete tags #{tagsStr} from server #{@chef_node_name}: #{cmd[0]}", 500) unless cmd[1]
      create_response("Deleted tags for #{@chef_node_name}: #{tagsStr}")
    end
  end
end
