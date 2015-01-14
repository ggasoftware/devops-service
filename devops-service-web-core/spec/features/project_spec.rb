require_relative '../spec_helper'

describe 'Project GET routes' do
  
  before do
      make_auth
  end

  describe 'get /collections/projects' do
    before { get '/collections/projects' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get /project_servers' do
    before { get '/project_servers/foo' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of objects' do
      array_of_objects? last_response.body
    end
  end

  describe 'get project users for all envs' do
    before { get '/project/foo/users' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

  describe 'get project users for specific env' do
    before { get '/project/foo/users/dev' }

    it 'is ok' do
      expect(last_response.status).to eq 200
    end

    it 'is JSON array of strings' do
      array_of_strings? last_response.body
    end
  end

end
