require "providers/provider_factory"
require "routes/v2.0/base_routes"
require "commands/image"

module Version2_0
  class ImageRoutes < BaseRoutes

    include ImageCommands

    def initialize wrapper
      super wrapper
      puts "Image routes initialized"
    end

    after %r{\A/image(/[\w]+)?\z} do
      statistic
    end

    # Get devops images list
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #   - parameters:
    #     - provider=ec2|openstack -> return images for provider
    #
    # * *Returns* :
    #   [
    #     {
    #       "provider": "openstack",
    #       "name": "centos-6.4-x86_64",
    #       "remote_user": "root",
    #       "bootstrap_template": null,
    #       "id": "36dc7618-4178-4e29-be43-286fbfe90f50"
    #     }
    #   ]
    get "/images" do
      check_headers :accept
      check_privileges("image", "r")
      check_provider(params[:provider]) if params[:provider]
      images = BaseRoutes.mongo.images(params[:provider])
      json(images.map {|i| i.to_hash})
    end

    # Get raw images for :provider
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   - ec2
    #   [
    #     {
    #       "id": "ami-83e4bcea",
    #       "name": "amzn-ami-pv-2013.09.1.x86_64-ebs",
    #       "status": "available"
    #     }
    #   ]
    #   - openstack
    #   [
    #      {
    #       "id": "36dc7618-4178-4e29-be43-286fbfe90f50",
    #       "name": "centos-6.4-x86_64",
    #       "status": "ACTIVE"
    #     }
    #   ]
    get "/images/provider/:provider" do
      check_headers :accept
      check_privileges("image", "r")
      check_provider(params[:provider])
      json get_images(BaseRoutes.mongo, params[:provider])
    end

    # Get devops image by id
    #
    # * *Request*
    #   - method : GET
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   {
    #     "provider": "openstack",
    #     "name": "centos-6.4-x86_64",
    #     "remote_user": "root",
    #     "bootstrap_template": null,
    #     "id": "36dc7618-4178-4e29-be43-286fbfe90f50"
    #   }
    get "/image/:image_id" do
      check_headers :accept
      check_privileges("image", "r")
      json BaseRoutes.mongo.image(params[:image_id])
    end

    # Create devops image
    #
    # * *Request*
    #   - method : POST
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "id": "image id",
    #       "provider": "image provider",
    #       "remote_user": "user", -> the ssh username
    #       "bootstrap_template": null, -> specific bootstrap template name or nil
    #       "name": "image name"
    #     }
    #
    # * *Returns* :
    #   201 - Created
    post "/image" do
      check_headers
      check_privileges("image", "w")
      image = create_object_from_json_body
      BaseRoutes.mongo.image_insert Image.new(image)
      create_response "Created", nil, 201
    end

    # Update devops image
    #
    # * *Request*
    #   - method : PUT
    #   - headers :
    #     - Accept: application/json
    #     - Content-Type: application/json
    #   - body :
    #     {
    #       "id": "image id",
    #       "provider": "image provider",
    #       "remote_user": "user" -> the ssh username
    #       "bootstrap_template": null -> specific bootstrap template name or nil
    #       "name": "image name"
    #     }
    #
    # * *Returns* :
    #   200 - Updated
    put "/image/:image_id" do
      check_headers
      check_privileges("image", "w")
      BaseRoutes.mongo.image params[:image_id]
      image = Image.new(create_object_from_json_body)
      image.id = params[:image_id]
      BaseRoutes.mongo.image_update image
      create_response("Image '#{params[:image_id]}' has been updated")
    end

    # Delete devops image
    #
    # * *Request*
    #   - method : DELETE
    #   - headers :
    #     - Accept: application/json
    #
    # * *Returns* :
    #   200 - Deleted
    delete "/image/:image_id" do
      check_headers
      check_privileges("image", "w")
      projects = BaseRoutes.mongo.projects_by_image params[:image_id]
      unless projects.empty?
        ar = []
        projects.each do |p|
          ar += p.deploy_envs.select{|e| e.image == params[:image_id]}.map{|e| "#{p.id}.#{e.identifier}"}
        end
        raise DependencyError.new "Deleting is forbidden: Image is used in #{ar.join(", ")}"
      end

      r = BaseRoutes.mongo.image_delete params[:image_id]
      create_response("Image '#{params[:image_id]}' has been removed")
    end

  end
end
