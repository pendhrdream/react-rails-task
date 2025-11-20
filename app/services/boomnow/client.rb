module Boomnow
  class Client
    BASE_URL = 'https://app.boomnow.com'
    CLIENT_ID = 'boom_3a213702291c3df84814'
    CLIENT_SECRET = '76df8d0d9bf2a21b04b4a64504c1107ed9b4078b3a3b1fd722687a9f399e7c76'
    
    def initialize
      @connection = Faraday.new(url: BASE_URL) do |conn|
        conn.request :json
        conn.response :json, content_type: /\bjson$/
        conn.adapter Faraday.default_adapter
      end
    end
    
    def search(city:, adults:)
      token = access_token
      
      response = @connection.get('/open_api/v1/listings') do |req|
        req.headers['Authorization'] = "Bearer #{token}"
        req.params = {
          city: city,
          adults: adults
        }
      end
      
      handle_response(response)
    end
    
    private
    
    def access_token
      cached_token = Rails.cache.read('boomnow_access_token')
      return cached_token if cached_token
      
      response = @connection.post('/open_api/v1/auth/token') do |req|
        req.body = {
          client_id: CLIENT_ID,
          client_secret: CLIENT_SECRET
        }
      end
      
      if response.success?
        token_data = response.body
        token = token_data['access_token']
        expires_in = token_data['expires_in'] || 3600
        
        # Cache the token, subtracting 60 seconds as a buffer
        Rails.cache.write('boomnow_access_token', token, expires_in: expires_in - 60)
        token
      else
        raise "Failed to obtain access token: #{response.status} - #{response.body}"
      end
    end
    
    def handle_response(response)
      if response.success?
        response.body
      else
        raise "API request failed: #{response.status} - #{response.body}"
      end
    end
  end
end

