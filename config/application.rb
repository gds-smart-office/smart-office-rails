require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'telegram/bot'
require 'open-uri'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SmartOffice
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.after_initialize do
      @@telegram_bot_token =        ENV["telegram_bot_token"]
      @@pong_ip =                   ENV["pong_ip"]
      @@drone_ip =                  ENV["drone_ip"]
      @@restart_cooldown =          ENV["restart_cooldown"].to_f
      @@password =                  ENV["password"]

      run_bot
    end
    
    def run_bot
      @@thread ||= Thread.new do      
        while true do
          startTime = Time.now
          begin
            puts "telegram_bot: started"
            Telegram::Bot::Client.run(@@telegram_bot_token) do |bot|
              bot.listen do |message|
                messageTime = Time.now
                if (messageTime - startTime) > @@restart_cooldown
                  perform_action(bot, message)
                else
                  log(message, "cooldown,start=#{startTime},now=#{messageTime},elasped=#{messageTime - startTime}")
                end                
              end
            end
          rescue Exception => e
            p e.message
          end
        end
        puts "telegram_bot: terminated"      
      end
    end
    
    def perform_action(bot, message)
      case action(message)
        when "/#{@@password}"
          authenticate(bot, message)
        when '/pong'
          pong(bot, message)
        when '/drone'
          drone(bot, message)
        when '/help'
          help(bot, message)
        when '/debug'
          send_message(bot, message, "debug: #{user_info(message)} #{chat_info(message)}")
        else
          puts "telegram_bot: else #{message.text}"
      end
      createMessage(message)
    end

    def createMessage(message)
      Message.create(
        user_id: message.from.id,
        user_name: "#{message.from.first_name} #{message.from.last_name}",
        chat_id: message.chat.id,
        chat_title: getChatTitle(message),
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
      send_message(bot, message, "Welcome #{message.from.first_name}, you are successfully authenticated.")
    end
    
    def isAuthorized?(message)
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
      if isAuthorized?(message)
        send_photo_webcam(bot, message, @@pong_ip, "pong")
      else
        send_photo(bot, message, "forbidden.jpg")
      end
    end

    def drone(bot, message)
      if isAuthorized?(message)
        send_photo_webcam(bot, message, @@drone_ip, "drone")
      else
        send_photo(bot, message, "forbidden.jpg")
      end
    end
    
    def help(bot, message)
      help =  "They called me Ping La Pong.\n\n" +
              "You can control me by sending these commands:\n\n" +
              "/[password] - Authenticate, please get the password from my Creator\n" +
              "/pong - Check status for Ping Pong table\n" +
              "/drone - Check status for Drone meeting room\n"
      send_message(bot, message, help)      
    end
    
    # Helpers
    def send_photo_webcam(bot, message, webcam_ip, name)
      begin
        open("#{name}.jpg", 'wb') do |file|
          #   file << open("http://#{@@pong_ip}/photo.jpg").read         
          file << open("http://#{webcam_ip}",http_basic_authentication: ["admin", ""]).read
        end
        send_photo(bot, message, "#{name}.jpg")
      rescue Exception => e
        bot.api.send_message(chat_id: message.chat.id, text: e.message)
      end
    end
    
    def overlayImage(filename)
      dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
      src = Magick::Image.read(filename).first
      result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
      result.write('photo.jpg')
    end

    # Telegram bot api
    def send_message(bot, message, text)
      bot.api.send_message(chat_id: message.chat.id, text: text)
    end

    def send_photo(bot, message, filename)
      bot.api.send_photo(chat_id: message.chat.id, photo: File.new(filename))
    end    
    
    # Logger helpers
    def log(message, text="OK")
      puts "telegram_bot[#{action(message)}][#{user_info(message)}][#{chat_info(message)}]: #{text}"
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
      "chat=#{getChatTitle(message)}, #{message.chat.id}"
    end
    
    def getChatTitle(message)
      message.chat.type == "private" ? "private" : message.chat.title
    end
  end
end