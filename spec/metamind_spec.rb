require 'spec_helper'
require 'webmock/rspec'
require 'json'
require 'timecop'
require 'jwt'
require 'util'

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
        client.access_token
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

    it 'raise error for argumenterror on private_key' do
      stub_request(:post, 'https://api.metamind.io/v1/oauth2/token')
          .to_return(body: { access_token: 'ACCESS_TOKEN_EXAMPLE'}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})

      expect{ client = Metamind::Client.new(password: password, email: email) }
          .to raise_error(ArgumentError, 'At least one parameter must be specified: cert or private_key')
    end

    it 'raise error for argumenterror on email' do
      stub_request(:post, 'https://api.metamind.io/v1/oauth2/token')
          .to_return(body: { access_token: 'ACCESS_TOKEN_EXAMPLE'}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})

      expect{ client = Metamind::Client.new(private_key: private_key_path, password: password) }
          .to raise_error(ArgumentError, 'missing keyword: email')
    end
  end

  describe 'Call Salesforce MetaMind API' do
    let(:dataset_id) { '1' }
    let(:client) {
      stub_request(:post, 'https://api.metamind.io/v1/oauth2/token')
          .to_return(body: { access_token: 'ACCESS_TOKEN_EXAMPLE'}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      Metamind::Client.new(private_key: private_key_path, password: password, email: email)
    }
    let(:label_id) { '2' }
    let(:labels) { '2,3' }
    let(:example_id) { '4' }
    let(:name) { 'hoge' }
    let(:image_file_data) { 'aaa' }
    let(:train_dataset_params) {
      {
        name: '',
        datasetId: dataset_id,
        epochs: nil,
        learningRate: nil
      }
    }
    let(:model_id) { '5' }
    let(:url) { 'http://example.com/sample.jpg' }
    let(:base64string) { 'base64' }
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

    it 'get a label' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/labels/#{label_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_label dataset_id, label_id
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/labels/#{label_id}").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'create an example' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.create_example dataset_id, { name: name, label_id: label_id, data: image_file_data }
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'get an example' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_example dataset_id, example_id
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'get all examples' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_all_example dataset_id
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'delete an example' do
      stub_request(:delete, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.delete_example dataset_id, example_id
      expect(WebMock).to have_requested(:delete, "#{Metamind::METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'train a dataset' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/train")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.train_dataset train_dataset_params
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/train").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'get training status' do
      stub_request(:get, "#{Metamind::METAMIND_VISION_API}/train/#{model_id}")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.get_training_status model_id
      expect(WebMock).to have_requested(:get, "#{Metamind::METAMIND_VISION_API}/train/#{model_id}").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'predict with image url' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/predict")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.predict_with_url url
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/predict").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end

    it 'predict with image base64 string' do
      stub_request(:post, "#{Metamind::METAMIND_VISION_API}/predict")
          .to_return(body: {}.to_json, status: 200, headers: {'Content-Type' => 'application/json'})
      client.predict_with_base64 base64string
      expect(WebMock).to have_requested(:post, "#{Metamind::METAMIND_VISION_API}/predict").
          with(headers: { Authorization: "Bearer #{client.access_token}"})
    end
  end
end
