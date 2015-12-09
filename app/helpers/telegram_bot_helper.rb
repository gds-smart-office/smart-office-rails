require 'telegram/bot'
require 'open-uri'

module TelegramBotHelper
  def run_bot
    while true do
      startTime = Time.now
      begin
        puts "telegram_bot: started"
        Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
          bot.listen do |message|
            messageTime = Time.now
            if (messageTime - startTime) > @restart_cooldown
              perform_action(bot, message)
            else
              log(message, "cooldown,start=#{startTime},now=#{messageTime},elasped=#{messageTime - startTime}")
            end
          end
        end
      rescue Exception => e
        puts e.message
      end
    end
    puts "telegram_bot: terminated"
  end
  
  def perform_action(bot, message)
    case action(message)
      when "/#{@password}"
        authenticate(bot, message)
      when '/pong'
        pong(bot, message)
      when '/recep'
        recep(bot, message)
      when '/help'
        help(bot, message)
      when '/debug'
        post_message(bot, message, "debug: #{user_info(message)} #{chat_info(message)}")
      else
        puts "telegram_bot: else #{message.text}"
    end
    create_message(message)
  end
  
  def create_message(message)
    Message.create(
      user_id: message.from.id,
      user_name: "#{message.from.first_name} #{message.from.last_name}",
      chat_id: message.chat.id,
      chat_title: chat_title(message),
      action: action(message))
  end
  
  # Authentication
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
  
  # Actions
  def pong(bot, message)
    if is_authorized?(message)
      send_photo_webcam(bot, message, @pong_ip, "pong")
    else
      post_photo(bot, message, "forbidden.jpg")
    end
  end
  
  def recep(bot, message)
    if is_authorized?(message)
      send_photo_webcam(bot, message, @recep_ip, "recep")
    else
      post_photo(bot, message, "forbidden.jpg")
    end
  end
  
  def help(bot, message)
    help =  "Hello, I am Ping La Pong, you can control me by sending these commands:\n\n" +
      "/pong - Check status for Ping Pong table\n" +
      "/recep - Check status for door at Reception area\n\n" +
      "Don't get too excited and trigger happy in your chat group, you can be considerate by clicking @ppong_bot and sending the commands privately.\n\n" +
      "Of cuz only authorized folks can control me, please find my creators for the /[password].\n\n" +
      "If you wish to contribute, you can check out https://github.com/gds-smart-office/smart-office-rails\n"
  
    post_message(bot, message, help)
  end
  
  # Helpers
  def send_photo_webcam(bot, message, webcam_ip, name)
    begin
      open("#{name}.jpg", 'wb') do |file|
        #   file << open("http://#{@pong_ip}/photo.jpg").read         
        file << open("http://#{webcam_ip}",http_basic_authentication: ["admin", ""]).read
      end
      post_photo(bot, message, "#{name}.jpg")
    rescue Exception => e
      bot.api.post_message(chat_id: message.chat.id, text: e.message)
    end
  end
  
  def overlayImage(filename)
    dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
    src = Magick::Image.read(filename).first
    result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
    result.write('photo.jpg')
  end
  
  # Telegram bot api
  def post_message(bot, message, text)
    bot.api.send_message(chat_id: message.chat.id, text: text)
  end
  
  def post_photo(bot, message, filename)
    bot.api.send_photo(chat_id: message.chat.id, photo: File.new(filename))
  end
  
  # Logger helpers
  def log(message, text="OK")
    if message
      puts "telegram_bot[#{action(message)}][#{user_info(message)}][#{chat_info(message)}]: #{text}"
    else
      puts "Nil Message!"
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
  
  def user_info(message)
    "user=#{message.from.first_name} #{message.from.last_name},#{message.from.id}"
  end
  
  def chat_info(message)
    "chat=#{chat_title(message)}, #{message.chat.id}"
  end
  
  def chat_title(message)
    message.chat.type == "private" ? "private" : message.chat.title
  end  
end