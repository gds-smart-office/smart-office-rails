require_relative "./logger_helper"

module UserHelper
  include LoggerHelper  
  
  def authenticate(bot, message)
    log(message, "authenticated")
    User.create(
      user_id: message.from.id,
      first_name: message.from.first_name,
      last_name: message.from.last_name,
      username: message.from.username
    )
    post_message(bot, message, "Welcome #{message.from.first_name}, you are successfully authenticated.")
  end

  def is_authorized?(user_id)
    isAuthorized = User.exists?(user_id: user_id)
    if isAuthorized
      puts "#{user_id} is authorized"
      # log(message, "authorized")
    else
      puts "#{user_id} is unauthorized"
      # log(message, "unauthorized")
    end
    isAuthorized
  end  
end