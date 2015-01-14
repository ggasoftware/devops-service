require_relative '../spec_helper'

describe 'Script GET routes' do
  
  before do
      make_auth
  end

  describe 'get scripts' do
    before { get '/collections/scripts' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

end
