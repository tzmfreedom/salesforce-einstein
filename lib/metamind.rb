require "metamind/version"
require "jwt"
require "net/https"


module Metamind
  # Your code goes here...
  class Client
    def initialize cert: nil, private_key: nil, password: nil, email: nil
      if !cert.nil?
        pkcs12 = OpenSSL::PKCS12::new(File.read(cert), password)
        @private_key = pkcs12.key
      elsif !private_key.nil?
        @private_key = private_key
      end
      @email = email
    end

    def authorize
      jwt = JWT.encode({
                     iss: 'developer.force.com',
                     sub: @email,
                     aud: 'https://api.metamind.io/v1/oauth2/token',
                     iat: Time.now.to_i,
                     exp: Time.now.to_i + 300
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

    def predict url: nil
      uri = URI.parse('https://api.metamind.io/v1/vision/predict')
      http = Net::HTTP.new(uri.host, uri.port)

      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.set_debug_output($stderr)

      req = Net::HTTP::Post.new(uri.path)
      # req['Content-Type'] = 'multipart/form-data'
      req['Authorization'] = "Bearer #{@access_token}"
      req.body = {sampleLocation: url, modelId: 'GeneralImageClassifier'}.map{|k,v|
        URI.encode(k.to_s) + "=" + URI.encode(v.to_s)
      }.join("&")

      res = http.request(req)
      JSON.parse(res.body)
    end
  end
end
