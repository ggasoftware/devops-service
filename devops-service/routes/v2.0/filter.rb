require "routes/v2.0/base_routes"

module Version2_0
  class FilterRoutes < BaseRoutes

    def initialize wrapper
      super wrapper
      puts "Filter routes initialized"
    end

    before "/filter/:provider/image" do
      check_headers :accept, :content_type
      check_privileges("filter", "w")
      check_provider(params[:provider])
      @images = create_object_from_json_body(Array)
      halt_response("Request body should not be an empty array") if @images.empty?
      check_array(@images, "Request body should contains an array with strings")
    end

    after "/filter/:provider/image" do
      statistic
    end

    # Get list of images filters for :provider
    #
    # Devops can works with images from filters list only
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* : array of strings
    #   - ec2:
    #   [
    #     "ami-83e4bcea"
    #   ]
    #   - openstack:
    #   [
    #     "36dc7618-4178-4e29-be43-286fbfe90f50"
    #   ]
    get "/filter/:provider/images" do
      check_headers :accept
      check_privileges("filter", "r")
      check_provider(params[:provider])
      json BaseRoutes.mongo.available_images(params[:provider])
    end

    # Add image ids to filter for :provider
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     [
    #       "image_id"
    #     ] -> array of image ids to add to filter
    #
    # * *Returns* : list of images filters for :provider
    put "/filter/:provider/image" do
      create_response("Updated", {:images => BaseRoutes.mongo.add_available_images(@images, params[:provider])})
    end

    # Delete image ids from filter for :provider
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     [
    #       "image_id"
    #     ] -> array of image ids to delete from filter
    #
    # * *Returns* : list of images filters for :provider
    delete "/filter/:provider/image" do
      create_response("Deleted", {:images => BaseRoutes.mongo.delete_available_images(@images, params[:provider])})
    end

  end
end
