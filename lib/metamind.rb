require 'metamind/version'
require 'jwt'
require 'net/https'
require 'securerandom'

module Metamind
  CRLF = "\r\n"
  METAMIND_VISION_API = 'https://api.metamind.io/v1/vision'

  class Client
    def initialize cert: nil, private_key: nil, password: nil, email:
      if cert.nil? && private_key.nil?
        raise ArgumentError.new 'At least one parameter must be specified: cert or private_key'
      end

      if !cert.nil?
        pkcs12 = OpenSSL::PKCS12::new(File.read(cert), password)
        @private_key = pkcs12.key
      elsif !private_key.nil?
        @private_key = OpenSSL::PKey::RSA.new(File.read(private_key), password)
      end
      @email = email
      @boundary = SecureRandom.hex(10)
    end

    def access_token
      get_access_token if @access_token.nil?
      @access_token
    end

    def predict_with_url url, modelId = 'GeneralImageClassifier'
      post "/predict", {sampleLocation: url, modelId: modelId}
    end

    # def predict_with_file path, modelId = 'GeneralImageClassifier'
    #   post "#{METAMIND_VISION_API}/predict", {sampleContent: path, modelId: modelId}
    # end

    def predict_with_base64 base64_string, modelId = 'GeneralImageClassifier'
      post "#{METAMIND_VISION_API}/predict", {sampleBase64Content: base64_string, modelId: modelId}
    end

    def create_dataset name, labels
      post "#{METAMIND_VISION_API}/datasets", {name: name, labels: labels}
    end

    def get_all_datasets
      get "#{METAMIND_VISION_API}/datasets"
    end

    def get_dataset dataset_id
      get "#{METAMIND_VISION_API}/datasets/#{dataset_id}"
    end

    def delete_dataset dataset_id
      delete "#{METAMIND_VISION_API}/datasets/#{dataset_id}"
    end

    def create_label dataset_id, name
      post "#{METAMIND_VISION_API}/datasets/#{dataset_id}/labels", name: name
    end

    def get_label dataset_id, label_id
      get "#{METAMIND_VISION_API}/datasets/#{dataset_id}/labels/#{label_id}"
    end

    def create_example dataset_id, params
      post "#{METAMIND_VISION_API}/datasets/#{dataset_id}/examples", params
    end

    def get_example dataset_id, example_id
      get "#{METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}"
    end

    def get_all_example dataset_id
      get "#{METAMIND_VISION_API}/datasets/#{dataset_id}/examples"
    end

    def delete_example dataset_id, example_id
      delete "#{METAMIND_VISION_API}/datasets/#{dataset_id}/examples/#{example_id}"
    end

    def train_dataset params
      post "#{METAMIND_VISION_API}/train", params
    end

    def get_training_status model_id
      get "#{METAMIND_VISION_API}/train/#{model_id}"
    end

    def get_model_metrics model_id
      get "#{METAMIND_VISION_API}/models/#{model_id}"
    end

    def get_all_models dataset_id
      get "#{METAMIND_VISION_API}/datasets/#{dataset_id}/models"
    end

    private

    def get url
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Get.new(uri.path)
      req['Accept-Encoding'] = 'identity'
      req['Authorization'] = "Bearer #{access_token}"

      res = http.request(req)
      JSON.parse(res.body)
    end

    def post url, params
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Post.new(uri.path)
      req['Content-Type'] = "multipart/form-data; boundary=#{@boundary}"
      req['Authorization'] = "Bearer #{access_token}"
      req.body = build_multipart_query(params)

      res = http.request(req)
      JSON.parse(res.body)
    end

    def delete url
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Delete.new(uri.path)
      req['Authorization'] = "Bearer #{access_token}"

      res = http.request(req)
      JSON.parse(res.body)
    end

    def build_multipart_query params
      parts = []
      params.each do |k, v|
        lines = []
        if v.is_a?(File)
          lines << "--#{@boundary}"
          lines << %Q{Content-Disposition: attachment; name="#{k}"}
          lines << "Content-type: image/#{File.extname(v)[1..-1]}"
          lines << "Content-Transfer-Encoding: binary"
          lines << ""
          lines << v.read
        else
          lines << "--#{@boundary}"
          lines << %Q{Content-Disposition: form-data; name="#{k}"}
          lines << ""
          lines << v
        end
        parts << lines.join(CRLF)
      end
      parts.join(CRLF) + "#{CRLF}--#{@boundary}--"
    end

    def get_access_token
      jwt = JWT.encode({
                           iss: 'developer.force.com',
                           sub: @email,
                           aud: 'https://api.metamind.io/v1/oauth2/token',
                           iat: Time.now.to_i,
                           exp: Time.now.to_i + 3600
                       }, @private_key, 'RS256')

      uri = URI.parse('https://api.metamind.io/v1/oauth2/token')
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data({grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt})

      res = http.request(req)
      @access_token = JSON.parse(res.body)['access_token']
    end
  end
end
