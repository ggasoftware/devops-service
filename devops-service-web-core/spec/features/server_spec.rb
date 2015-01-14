require_relative '../spec_helper'

describe 'Server GET routes' do
  
  before do
      make_auth
  end

  describe 'get servers' do
    before { get '/collections/servers' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get server' do
    before { get '/models/server/devops-foo-dev-1415336498' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON hash' do
      object? last_response.body
    end
  end


end
