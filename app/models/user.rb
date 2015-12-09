require 'securerandom'

class User < ActiveRecord::Base
  before_create :set_auth_token

  private
    def set_auth_token
      return if auth_token.present?
      self.auth_token = generate_auth_token
    end
  
    def generate_auth_token
      SecureRandom.uuid.gsub(/\-/,'')
    end
end