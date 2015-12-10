module LoggerHelper
  def log_message(message, text="OK")
    if message
      puts "telegram_bot[#{action(message)}][#{user_info(message)}][#{chat_info(message)}]: #{text}"
    else
      puts "Nil Message!"
    end 
  end

  def log(text="OK")
      puts "telegram_bot: #{text}"
  end

  def user_info(message)
    "user=#{message.from.first_name} #{message.from.last_name},#{message.from.id}"
  end

  def chat_info(message)
    "chat=#{chat_title(message)}, #{message.chat.id}"
  end
end