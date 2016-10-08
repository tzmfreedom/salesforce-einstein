require 'metamind/version'
require 'jwt'
require 'net/https'
require 'securerandom'


module Metamind
  CRLF = "\r\n"

  class Client
    def initialize cert: nil, private_key: nil, password: nil, email: nil
      if !cert.nil?
        pkcs12 = OpenSSL::PKCS12::new(File.read(cert), password)
        @private_key = pkcs12.key
      elsif !private_key.nil?
        @private_key = private_key
      end
      @email = email
      @boundary = SecureRandom.hex(10)
    end

    def authorize
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
      # http.set_debug_output($stderr)

      req = Net::HTTP::Post.new(uri.path)
      req.set_form_data({grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer', assertion: jwt})

      res = http.request(req)
      @access_token = JSON.parse(res.body)['access_token']
    end

    def predict_by_url url, modelId = 'GeneralImageClassifier'
      post 'https://api.metamind.io/v1/vision/predict', {sampleLocation: url, modelId: modelId}
    end

    def predict_by_file path, modelId = 'GeneralImageClassifier'
      post 'https://api.metamind.io/v1/vision/predict', {sampleContent: path, modelId: modelId}
    end

    def predict_by_base64 base64_string, modelId = 'GeneralImageClassifier'
      post 'https://api.metamind.io/v1/vision/predict', {sampleBase64Content: base64_string, modelId: modelId}
    end

    private

    def post url, params
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.set_debug_output($stderr)

      req = Net::HTTP::Post.new(uri.path)
      req['Content-Type'] = "multipart/form-data; boundary=#{@boundary}"
      req['Authorization'] = "Bearer #{@access_token}"
      req.body = build_multipart_query(params)
      puts req.body

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
  end
end
