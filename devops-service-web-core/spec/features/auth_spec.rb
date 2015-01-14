require_relative '../spec_helper'

describe 'Auth routes' do

  describe 'GET /login' do
    before { get '/login' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end
  end

  describe 'GET /logout' do
    before { get '/logout' }

    it 'is ok' do
      expect(last_response.status).to eq 302
      expect(last_response.headers["Location"].end_with? "/login")
    end
  end

end
