require_relative '../spec_helper'

describe 'Key GET routes' do
  
  before do
    make_auth
  end

  describe 'get keys' do
    before { get '/collections/keys' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

end
