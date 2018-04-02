require 'jwt'
require 'net/https'
require 'faraday'
require 'securerandom'
require 'salesforce/einstein/vision'

module Salesforce
  module Einstein
    module V2
      class Client
        include Vision

        CRLF = "\r\n"
        BASE_URI = 'https://api.einstein.ai/v2'

        attr_accessor :boundary, :email, :private_key, :access_token, :timeout

        def initialize(cert: nil, private_key: nil, password: nil, email:, timeout: 3600)
          if cert.nil? && private_key.nil?
            raise ArgumentError.new 'At least one parameter must be specified: cert or private_key'
          end

          if cert
            cert_contents = File.read(File.expand_path(cert))
            pkcs12 = OpenSSL::PKCS12::new(cert_contents, password)
            @private_key = pkcs12.key
          else
            private_key_contents = File.read(File.expand_path(private_key))
            @private_key = OpenSSL::PKey::RSA.new(private_key_contents, password)
          end
          @email = email
          @boundary = SecureRandom.hex(10)
          @timeout = 3600
        end

        def access_token
          @token_info ||= get_access_token
          @token_info['access_token']
        end

        def get_api_usage
          get '/apiusage'
        end

        def delete_reflesh_token(token)
          delete "/oauth2/token/#{token}"
        end

        private

        def client
          @client ||= Faraday.new do |conn|
            conn.request :multipart
            conn.request :url_encoded
            conn.adapter :net_http
          end
        end

        def get(path)
          response = client.get do |req|
            req.url "#{BASE_URI}#{path}"
            req.headers['Authorization'] = "Bearer #{access_token}"
          end
          response ? JSON.parse(response.body) : nil
        end

        def post(path, params)
          response = client.post do |req|
            req.url "#{BASE_URI}#{path}"
            req.headers['Content-Type'] = 'multipart/form-data'
            req.headers['Authorization'] = "Bearer #{access_token}"
            req.body = params
          end
          response ? JSON.parse(response.body) : nil
        end

        def delete(path)
          response = client.delete do |req|
            req.url "#{BASE_URI}#{path}"
            req.headers['Content-Type'] = 'multipart/form-data'
            req.headers['Authorization'] = "Bearer #{access_token}"
          end
          response ? JSON.parse(response.body) : nil
        end

        def get_access_token
          jwt = JWT.encode({
                             iss: 'developer.force.com',
                             sub: email,
                             aud: "#{BASE_URI}/oauth2/token",
                             iat: Time.now.to_i,
                             exp: Time.now.to_i + timeout
                           }, private_key, 'RS256')

          response = client.post do |req|
            req.url "#{BASE_URI}/oauth2/token"
            req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
            req.body = {
              grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
              assertion: jwt
            }
          end
          response ? JSON.parse(response.body) : nil
        end
      end
    end

    Client = V2::Client
  end
end

