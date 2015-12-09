class Api::ApiController < ActionController::Base
  private
    def api_authenticate
      authenticate_or_request_with_http_token do |token, options|
        User.find_by(auth_token: token)
      end
    end
end