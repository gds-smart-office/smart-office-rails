module UserHelper
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

  def is_authorized?(message)
    isAuthorized = User.exists?(user_id: message.from.id)
    if isAuthorized
      log(message, "authorized")
    else
      log(message, "unauthorized")
    end
    isAuthorized
  end  
end