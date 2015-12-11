module LoggerHelper
  def log_message(message, text="OK")
    if message
      puts "telegram_bot[#{action(message)}][#{user_info(message)}][#{chat_info(message)}]: #{text}"
    else
      puts "Nil Message!"
    end 
  end

  def log(text="OK", options = {})
    info = ""
    if !options[:action].nil?
      info += "[action=#{options[:action]}]"
    end
    if !options[:user_id].nil?
      info += "[user=#{options[:user_id]}]"
    end
    if !options[:chat_id].nil?
      info += "[chat=#{options[:chat_id]}]"
    end
      puts "telegram_bot#{info}: #{text}"
  end

  def user_info(message)
    "user=#{message.from.first_name} #{message.from.last_name},#{message.from.id}"
  end

  def chat_info(message)
    "chat=#{chat_title(message)},#{message.chat.id}"
  end
end