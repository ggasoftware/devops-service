require_relative '../spec_helper'

describe 'Group GET routes' do
  
  before do
      make_auth
  end

  describe 'get groups', broken: true do
    before { get '/collections/groups/openstack' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get flavors', broken: true do
    before { get '/collections/groups/ec2' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

end
