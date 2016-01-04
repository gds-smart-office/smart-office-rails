require "#{Rails.root}/app/helpers/telegram_bot_helper"

require "google/api_client"
require "google_drive"

namespace :attendance_bot do
  include TelegramBotHelper
  
  desc "TODO"
  task run: :environment do
    @telegram_bot_token = ENV["telegram_bot_token"]
    @gsheet_key = ENV["gsheet_key"]
    @gdrive_api_id = ENV["gdrive_api_id"]
    @gdrive_api_secret = ENV["gdrive_api_secret"]
    @broadcast_chat_id = ENV["broadcast_chat_id"]
    
    today = Date.today
    users = get_on_leave_users(today)
    message = on_leave_message(users, today)
    send_telegram_message(message)
  end
  
  def get_on_leave_users(date)
    config = "{\"client_id\": \"#{@gdrive_api_id}\",\"client_secret\": \"#{@gdrive_api_secret}\"}"
    session = GoogleDrive.saved_session(config)
    ws = session.spreadsheet_by_key(@gsheet_key).worksheets[0]
    
    r = 2
    user = ws[r, 1]
    users = []
    while !user.blank? do
      begin
        start_date = Date.parse(ws[r, 2])
        end_date = Date.parse(ws[r, 3])
        if (end_date - start_date) < 365 && date.between?(start_date, end_date)
          users.append(user)
        end
      rescue Exception => e
        p "attendance_bot[#{user}]: #{e.message}"
      ensure
        r = r + 1
        user = ws[r, 1]
      end
    end
    users
  end
  
  def on_leave_message(users, date)
    message = "Hi everyone, today (#{date.strftime('%d %b %Y')}) "
    if users.count == 0
      message += "no one is out-of-office.\n"
    else
      message += "the following personnel are out-of-office:\n"
      users.each_with_index do |user, index|
        message += "#{index+1}. #{user}\n"
      end
    end
    message
  end
  
  def send_telegram_message(message)
    Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
      p "attendance_bot[#{@broadcast_chat_id}]: #{message}"
      post_message(bot, @broadcast_chat_id, message)
    end
  end
end
