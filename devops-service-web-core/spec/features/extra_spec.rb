require_relative '../spec_helper'

describe 'Extra GET routes' do
  
  before do
      make_auth
  end

  describe 'get app options' do
    before { get '/app/options' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON hash' do
      object? last_response.body
    end
  end

end
