require_relative '../spec_helper'

describe 'Template GET routes' do
  
  before do
      make_auth
  end

  describe 'get templates' do
    before { get '/collections/templates' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

end
