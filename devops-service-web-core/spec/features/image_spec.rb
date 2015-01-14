require_relative '../spec_helper'

describe 'Image GET routes' do
  
  before do
      make_auth
  end

  describe 'get images' do
    before { get '/collections/images' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get openstack images', broken: true do
    before { get '/collections/images/openstack' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get image' do
    test_image = cfg["test_data"]["image"]
    before { get "/models/image/#{test_image}" }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON object' do
      object? last_response.body
    end
  end

end
