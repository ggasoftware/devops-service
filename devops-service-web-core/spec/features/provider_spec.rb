require_relative '../spec_helper'

describe 'Provider GET routes' do
  
  before do
      make_auth
  end

  describe 'get providers' do
    before { get '/collections/providers' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings', broken: true do
      array_of_strings? last_response.body
    end
  end

end
