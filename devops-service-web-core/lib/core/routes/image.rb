module Sinatra::DevopsServiceWeb::Core::Routing::Image
          
  def self.registered(app)

    create = lambda do
      api_call("/image", method: :post, data: JSON.pretty_generate(params))
    end

    get_images = lambda do
      api_call("/images?provider=#{params[:provider]}")
    end

    get_available_images_for_provider = lambda  do
      api_call("/images/provider/#{params[:provider]}")
    end

    app.post '/image', &create
    app.get '/images/:provider', &get_images
    app.get '/collections/images/provider/:provider', &get_available_images_for_provider

  end
      
end
