require 'telegram/bot'
require 'open-uri'
require 'RMagick'

token = 'your_telegram_bot_token'
webcam_ip = 'your_web_cam_ip'
authorized_chats = []
easter_egg = true

def overlayImage(filename)
  dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
  src = Magick::Image.read(filename).first
  result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
  result.write('photo.jpg')
end

Telegram::Bot::Client.run(token) do |bot|
  puts "smart-office started"  
  bot.listen do |message|
    case message.text
      when '/debug'      
        bot.api.send_message(chat_id: message.chat.id, text: "debug: #{message.from.first_name} from chat=#{message.chat.id}")
      when '/pong'
        puts "photo request from #{message.from.first_name} #{message.from.last_name}"
        if authorized_chats.include?(message.chat.id)
          puts "authorized"
          begin
            open('photo.jpg', 'wb') do |file|
              file << open("http://#{webcam_ip}/photo.jpg").read
            end
            t = Time.now
            if easter_egg && t.hour == 20
              puts "hour=#{t.hour} within time range, easter_egg=#{easter_egg}"
              overlayImage("ghost.png")
              easter_egg = false
            else
              puts "hour=#{t.hour} outside time range, easter_egg=#{easter_egg}"              
            end
            bot.api.send_photo(chat_id: message.chat.id, photo: File.new("photo.jpg"))
          rescue Exception => e  
            bot.api.send_message(chat_id: message.chat.id, text: e.message)
          end
        else
          puts "unauthorized"          
          bot.api.send_photo(chat_id: message.chat.id, photo: File.new("forbidden.jpg"))
        end
      when '/overlay'
          overlayImage("ghost.png")
          bot.api.send_photo(chat_id: message.chat.id, photo: File.new("photo.jpg"))
      else
        puts "else #{message.text}"
    end
  end  
end
