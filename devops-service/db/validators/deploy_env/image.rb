require "commands/image"

module Validators
  class DeployEnv::Image < Base
    include ::ImageCommands

    def valid?
      images = get_images(DevopsService.mongo, @model.provider)
      images.detect do |image|
        image["id"] == @model.image
      end
    end

    def message
      "Invalid image '#{@model.image}'."
    end
  end
end