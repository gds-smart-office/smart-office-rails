require 'telegram/bot'
require 'open-uri'

class RegisterController < ApplicationController
  def index
  end
  
  def register
    name = params[:name]
    person = params[:person]
    @@pong_ip =                   ENV["pong_ip"]
    @@drone_ip =                  ENV["drone_ip"]
    @@telegram_bot_token =        ENV["telegram_bot_token"]
    Telegram::Bot::Client.run(@@telegram_bot_token) do |bot|
      caption = "#{name} is at the reception area, looking for #{person}"
      # send_photo_webcam(bot, @@pong_ip, "pong", caption)
      send_photo_webcam(bot, @@drone_ip, "drone", caption)
    end
    
    render :json => {:message => "OK"}
  end

  def send_photo_webcam(bot, webcam_ip, name, caption)
    begin
      open("#{name}.jpg", 'wb') do |file|
        #   file << open("http://#{@@pong_ip}/photo.jpg").read         
        file << open("http://#{webcam_ip}",http_basic_authentication: ["admin", ""]).read
      end
      bot.api.send_photo(chat_id: -51984018, caption: caption, photo: File.new("#{name}.jpg"))
    rescue Exception => e
      bot.api.send_message(chat_id: message.chat.id, text: e.message)
    end
  end
end