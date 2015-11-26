require 'telegram/bot'
require 'open-uri'
# require 'rmagick'
require './params'

token = Params::TOKEN
webcam_ip = Params::WEBCAM_IP
restart_cooldown = Params::RESTART_COOLDOWN
authorized_chats = Params::AUTHORIZED_CHATS
easter_egg = true

def overlayImage(filename)
  # dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
  # src = Magick::Image.read(filename).first
  # result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
  # result.write('photo.jpg')
end

puts "~~~~"  
while true do
  startTime = Time.now
  begin 
    Telegram::Bot::Client.run(token) do |bot|
      puts "smart-office started"  
      bot.listen do |message|
        messageTime = Time.now
        if (messageTime - startTime) > restart_cooldown
          case message.text
            when '/debug'      
              bot.api.send_message(chat_id: message.chat.id, text: "debug: #{message.from.first_name} from chat=#{message.chat.id}")
            when '/pong2'
              puts "photo request from #{message.from.first_name} #{message.from.last_name}"
              if authorized_chats.include?(message.chat.id)
                puts "authorized"
                begin
                  open('photo.jpg', 'wb') do |file|
                    file << open("http://#{Params::WEBCAM_IP}",http_basic_authentication: ["admin", ""]).read
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
          end
        else
          print "Start:#{startTime}\n"
          print "Now:#{messageTime}\n"
          print "Elasped#{messageTime - startTime}\n"
          print "Cooldown\n"
        end
      end  
    end
  rescue
    p "ops..."
  end
end