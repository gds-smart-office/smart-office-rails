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
      token = '122897784:AAGuY-JLZ2OSZwVCy_s_aq_I8FSwJbBQgko'
      puts "telegram_bot: started"
      Telegram::Bot::Client.run(token) do |bot|
        bot.listen do |message|
          case message.text
            when '/start'
              puts "telegram_bot: /start"
              bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
            when '/stop'
              puts "telegram_bot: /stop"
              bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
            else
              puts "telegram_bot: else"
          end
        end
      end
    end    
  end
end
