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
        p e.message
        p e.backtrace
      end
    end
    puts "telegram_bot: terminated"
  end

  def perform_action(bot, message)
    action = action(message) 
    user_id = message.from.id
    chat_id = message.chat.id
    chat_title = chat_title(message)
    log_message(message, "Request is made")
    
    case action(message)
      when "/#{@password}"
        authenticate(bot, message)
      when '/pong'
        telegram_pong(bot, user_id, chat_id)
      when '/recep'
        telegram_recep(bot, user_id, chat_id)
      when '/token'
        telegram_token(bot, user_id, chat_id)
      when '/follow'
        telegram_follow(bot, chat_id, chat_title)
      when '/unfollow'
        telegram_unfollow(bot, chat_id)
      when '/help'
        telegram_help(bot, chat_id)
      when '/info'
        post_message(bot, chat_id, "info: #{user_info(message)}|#{chat_info(message)}")
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
  
  def telegram_follow(bot, chat_id, chat_title)
    if Follower.find_by(chat_id: chat_id).nil?
      Follower.create(chat_id: chat_id, chat_title: chat_title)
    end
    post_message(bot, chat_id, "This chat has successfully followed self-checkin Reception area notifications.")
  end

  def telegram_unfollow(bot, chat_id)
    follower = Follower.find_by(chat_id: chat_id)
    if !follower.nil?
      follower.delete
    end
    post_message(bot, chat_id, "This chat has successfully unfollowed self-checkin Reception area notifications.")
  end  

  def telegram_help(bot, chat_id)
    help =  "Hello, I am Ping La Pong v2.0!\n\n" +
            "Now I am enchanced with a new feature called Pong as a Service (PongaaS). " +
            "You will be able to access my commands via secured APIs. " +
            "The API methods are available at the GitHub link below.\n\n" +
            "You can control me by sending these commands:\n" +
            "/pong - Check status for Ping Pong table\n" +
            "/recep - Check status for door at Reception area\n" +
            "/token - Get your auth token to access the API\n" +
            "/follow - Follow self-checkin Reception area notifications\n" +
            "/unfollow - Unfollow self-checkin Reception area notifications\n" +    
            "/info - Get your user id and chat id for the API\n\n" +    
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
