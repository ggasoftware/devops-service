require "providers/provider_factory"

module ImageCommands

  def get_images mongo, provider
    filters = mongo.available_images(provider)
    if filters.empty?
      []
    else
      ::Version2_0::Provider::ProviderFactory.get(provider).images(filters)
    end
  end
end
