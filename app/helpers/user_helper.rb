require_relative "./logger_helper"

module UserHelper
  include LoggerHelper  
  
  def authenticate(bot, message)
    log_message(message, "authenticated")
    user_id = message.from.id
    if User.find_by(user_id: user_id)
    User.create(
      user_id: user_id,
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username,
      email: "#{message.from.username}@example.com",
      password: "password",
      password_confirmation: "password",
    )
    end
    post_message(bot, message.chat.id, "Welcome #{message.from.first_name}, you are successfully authenticated.")
  end

  def is_authorized?(user_id)
    isAuthorized = User.exists?(user_id: user_id)
    if isAuthorized
      log("#{user_id} is authorized")
    else
      log("#{user_id} is unauthorized")
    end
    isAuthorized
  end  
  
  def get_auth_token(user_id)
    User.find_by(user_id: user_id).auth_token
  end
end