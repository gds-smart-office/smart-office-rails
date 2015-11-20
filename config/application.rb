require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'telegram/bot'

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
      @@thread ||= Thread.new do
        start_telegram_bot
      end
    end
    
    def start_telegram_bot
      telegram_bot_token = ENV["telegram_bot_token"]
      telegram_authorized_chats = ENV["telegram_authorized_chats"].split(",").map(&:to_i)      
      web_cam_ip = ENV["web_cam_ip"]
      
      puts "telegram_bot: started"
      Telegram::Bot::Client.run(telegram_bot_token) do |bot|
        bot.listen do |message|
          case message.text
            when '/pong'
              puts "telegram_bot: photo request from #{message.from.first_name} #{message.from.last_name}"
              if telegram_authorized_chats.include?(message.chat.id)
                puts "telegram_bot: authorized"
                begin
                  open('photo.jpg', 'wb') do |file|
                    file << open("http://#{web_cam_ip}/photo.jpg").read
                  end
                  bot.api.send_photo(chat_id: message.chat.id, photo: File.new("photo.jpg"))
                rescue Exception => e
                  bot.api.send_message(chat_id: message.chat.id, text: e.message)
                end
              else
                puts "telegram_bot: unauthorized"
                bot.api.send_photo(chat_id: message.chat.id, photo: File.new("forbidden.jpg"))
              end
            when '/debug'
              bot.api.send_message(chat_id: message.chat.id, text: "debug: #{message.from.first_name} from chat=#{message.chat.id}")
            else
              puts "telegram_bot: else"
          end
        end
      end
    end

    def overlayImage(filename)
      dst = Magick::Image.read("photo.jpg") {self.size = "640x480"}.first
      src = Magick::Image.read(filename).first
      result = dst.composite(src, Magick::CenterGravity, Magick::OverCompositeOp)
      result.write('photo.jpg')
    end    

  end
end
