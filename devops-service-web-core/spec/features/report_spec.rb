require_relative '../spec_helper'

describe 'Report GET routes' do
  
  before do
      make_auth
  end

  describe 'get reports' do
    before { get '/api/reports' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON object' do
      object? last_response.body
    end
  end

end
