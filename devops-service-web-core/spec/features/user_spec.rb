require_relative '../spec_helper'

describe 'User GET routes' do
  
  before do
      make_auth
  end

  describe 'get users' do
    before { get '/collections/users' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON objects' do
      array_of_objects? last_response.body
    end

  end

end
