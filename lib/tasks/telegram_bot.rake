require "#{Rails.root}/app/helpers/logger_helper"
require "#{Rails.root}/app/helpers/telegram_bot_helper"
require "#{Rails.root}/app/helpers/message_helper"
require 'telegram/bot'

namespace :telegram_bot do
  include LoggerHelper
  include TelegramBotHelper
  include MessageHelper
  
  desc "TODO"
  task run: :environment do
    @telegram_bot_token = ENV["telegram_bot_token"]
    @pong_ip = ENV["pong_ip"]
    @recep_ip = ENV["recep_ip"]
    @restart_cooldown = ENV["restart_cooldown"].to_f
    @password = ENV["password"]
    run_bot    
  end

  def run_bot
    while true do
      startTime = Time.now
      begin
        puts "telegram_bot: started"
        Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
          bot.listen do |message|
            messageTime = Time.now
            if (messageTime - startTime) > @restart_cooldown
              if message != nil && message.text != nil
                perform_action(bot, message)
              end
            else
              log_message(message, "cooldown,start=#{startTime},now=#{messageTime},elasped=#{messageTime - startTime}")
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
    action = action(message) 
    user_id = message.from.id
    chat_id = message.chat.id
    
    case action(message)
      when "/#{@password}"
        authenticate(bot, message)
      when '/pong'
        pong(bot, user_id, chat_id)
      when '/recep'
        recep(bot, user_id, chat_id)
      when '/help'
        help(bot, user_id)
      when '/debug'
        post_message(bot, message, "debug: #{user_info(message)} #{chat_info(message)}")
      else
        puts "telegram_bot: else #{message.text}"
    end
    create_message(message)
  end
end
