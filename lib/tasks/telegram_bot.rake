require "#{Rails.root}/app/helpers/logger_helper"
require "#{Rails.root}/app/helpers/telegram_bot_helper"
require "#{Rails.root}/app/helpers/user_helper"
require "#{Rails.root}/app/helpers/message_helper"
require 'telegram/bot'

namespace :telegram_bot do
  include LoggerHelper
  include TelegramBotHelper
  include UserHelper
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
        telegram_pong(bot, user_id, chat_id)
      when '/recep'
        telegram_recep(bot, user_id, chat_id)
      when '/token'
        telegram_token(bot, user_id, chat_id)
      when '/help'
        telegram_help(bot, user_id)
      when '/info'
        post_message(bot, message, "info: #{user_info(message)} #{chat_info(message)}")
      else
        puts "telegram_bot: else #{message.text}"
    end
    create_message(message)
  end

  def telegram_pong(bot, user_id, chat_id, options = {})
    code = pong(bot, user_id, chat_id, options)
    render_response(bot, chat_id, code)
  end

  def telegram_recep(bot, user_id, chat_id, options = {})
    code = recep(bot, user_id, chat_id, options)
    render_response(bot, chat_id, code)
  end
  
  def telegram_token(bot, user_id, chat_id)
    code = token(bot, user_id, chat_id)
    render_response(bot, chat_id, code)
  end

  def telegram_help(bot, chat_id)
    help =  "Hello, I am Ping La Pong, you can control me by sending these commands:\n\n" +
            "/pong - Check status for Ping Pong table\n" +
            "/recep - Check status for door at Reception area\n\n" +
            "/token - Get your auth token to access the API\n" +
            "/info - Get the information of your id and chat id\n" +    
            "Don't get too excited and trigger happy in your chat group, you can be considerate by clicking @ppong_bot and sending the commands privately.\n\n" +
            "Of cuz only authorized folks can control me, please find my creators for the /[password].\n\n" +
            "If you wish to contribute, you can check out https://github.com/gds-smart-office/smart-office-rails\n"
    post_message(bot, chat_id, help)
  end
  
  def render_response(bot, chat_id, code)
    case code
      when :error
        post_message(bot, chat_id, "Oops something went wrong!")
      when :unauthorized
        post_photo(bot, chat_id, "forbidden.jpg")
    end    
  end
end
