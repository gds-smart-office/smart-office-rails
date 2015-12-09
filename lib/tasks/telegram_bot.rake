require "#{Rails.root}/app/helpers/telegram_bot_helper"
require 'telegram/bot'

namespace :telegram_bot do
  include TelegramBotHelper
  
  desc "TODO"
  task run: :environment do
    @telegram_bot_token = ENV["telegram_bot_token"]
    @pong_ip = ENV["pong_ip"]
    @recep_ip = ENV["recep_ip"]
    @restart_cooldown = ENV["restart_cooldown"].to_f
    @password = ENV["password"]
    run_bot
  end
end
