require 'telegram/bot'
require 'open-uri'
require_relative "./user_helper"

module TelegramBotHelper
  include UserHelper
  
  def pong(bot, user_id, chat_id)
    if is_authorized?(user_id)
      send_photo_webcam(bot, chat_id, @pong_ip, "pong")
    else
      post_photo(bot, chat_id, "forbidden.jpg")
    end
  end
  
  def recep(bot, user_id, chat_id)
    if is_authorized?(user_id)
      send_photo_webcam(bot, chat_id, @recep_ip, "recep")
    else
      post_photo(bot, chat_id, "forbidden.jpg")
    end
  end
  
  def help(bot, chat_id)
    help =  "Hello, I am Ping La Pong, you can control me by sending these commands:\n\n" +
            "/pong - Check status for Ping Pong table\n" +
            "/recep - Check status for door at Reception area\n\n" +
            "Don't get too excited and trigger happy in your chat group, you can be considerate by clicking @ppong_bot and sending the commands privately.\n\n" +
            "Of cuz only authorized folks can control me, please find my creators for the /[password].\n\n" +
            "If you wish to contribute, you can check out https://github.com/gds-smart-office/smart-office-rails\n"
    post_message(bot, chat_id, help)
  end
  
  def send_photo_webcam(bot, chat_id, webcam_ip, name)
    begin
      open("#{name}.jpg", 'wb') do |file|
        file << open("http://#{webcam_ip}", http_basic_authentication: ["admin", ""]).read
      end
      post_photo(bot, chat_id, "#{name}.jpg")
    rescue Exception => e
      post_message(bot, chat_id, e.message)
    end
  end
  
  def action(message)
    action = message.text
    index = action.index('@')
    if index != nil
      action = action[0..(index-1)]
    end
    action
  end

  def chat_title(message)
    message.chat.type == "private" ? "private" : message.chat.title
  end
  
  def post_message(bot, chat_id, text)
    bot.api.send_message(chat_id: chat_id, text: text)
  end

  def post_photo(bot, chat_id, filename)
    bot.api.send_photo(chat_id: chat_id, photo: File.new(filename))
  end  
end