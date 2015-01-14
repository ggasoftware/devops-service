require_relative '../spec_helper'

describe 'Network GET routes', :broken => true do
  
  before do
      make_auth
  end

  describe 'get openstack networks' do
    before { get '/collections/networks/openstack' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

  describe 'get ec2 networks' do
    before { get '/collections/networks/ec2' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

end
