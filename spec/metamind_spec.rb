require 'spec_helper'
require 'webmock/rspec'
require 'json'
require 'timecop'
require 'jwt'
require 'cgi'

class Object
  def to_query(key)
    "#{CGI.escape(key.to_s)}=#{CGI.escape(self.to_s)}"
  end
end

class Hash
  def to_query(namespace = nil)
    collect do |key, value|
      unless (value.is_a?(Hash) || value.is_a?(Array)) && value.empty?
        value.to_query(namespace ? "#{namespace}[#{key}]" : key)
      end
    end.compact * "&"
  end
end

describe Metamind do
  let(:private_key_path) { './spec/resource/private_key.pem' }
  let(:password) { 'password_example' }
  let(:email) { 'hoge@example.com' }
  it 'has a version number' do
    expect(Metamind::VERSION).not_to be nil
  end

  describe 'authorize' do
    it 'should return access token' do
      stub_request(:post, 'https://api.metamind.io/v1/oauth2/token')
        .to_return(body: { access_token: 'ACCESS_TOKEN_EXAMPLE'}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      Timecop.freeze(Time.now) do
        client = Metamind::Client.new(private_key: private_key_path, password: password, email: email)
        jwt = JWT.encode({
                             iss: 'developer.force.com',
                             sub: email,
                             aud: 'https://api.metamind.io/v1/oauth2/token',
                             iat: Time.now.to_i,
                             exp: Time.now.to_i + 3600
                         }, OpenSSL::PKey::RSA.new(File.read(private_key_path), password), 'RS256')

        expect(WebMock).to have_requested(:post, 'https://api.metamind.io/v1/oauth2/token').
          with(body: { grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt }.to_query,
               headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
        expect(client.access_token).to eq('ACCESS_TOKEN_EXAMPLE')
      end
    end
  end

  describe 'Call Salesforce MetaMind API' do
    let(:dataset_id) { '1' }
    let(:client) {
      stub_request(:post, 'https://api.metamind.io/v1/oauth2/token')
          .to_return(body: { access_token: 'ACCESS_TOKEN_EXAMPLE'}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      Metamind::Client.new(private_key: private_key_path, password: password, email: email)
    }
    before(:each) do
    end

    it 'get all datasets' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_all_datasets
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'get a dataset' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_dataset dataset_id
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}").
        with(headers: { Authorization: "Bearer #{client.access_token}"})
    end


    it 'delete a dataset' do
      stub_request(:delete, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.delete_dataset dataset_id
      expect(WebMock).to have_requested(:delete, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'create a dataset' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/datasets")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.create_dataset 'NAME', 'LABEL'
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/datasets").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'create a label' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/labels")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.create_label dataset_id, 'NAME'
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/labels").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end


    # it 'get all datasets' do
    #   stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets")
    #       .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
    #   @client.get_all_datasets
    #   expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets")
    # end
    # it 'get all datasets' do
    #   stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets")
    #       .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
    #   @client.get_all_datasets
    #   expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets")
    # end
  end
end
