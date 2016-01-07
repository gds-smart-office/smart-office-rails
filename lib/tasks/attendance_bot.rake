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
    personnels = get_on_leave_personnels(today)
    message = on_leave_message(personnels[0], personnels[1], today)
    send_telegram_message(message)
  end
  
  def get_on_leave_personnels(date)
    config = "{\"client_id\": \"#{@gdrive_api_id}\",\"client_secret\": \"#{@gdrive_api_secret}\"}"
    session = GoogleDrive.saved_session(config)
    ws = session.spreadsheet_by_key(@gsheet_key).worksheets[0]
    
    r = 2
    personnels = []
    personnels.append([])
    personnels.append([])
    while !ws[r, 1].blank? do
      begin
        personnel = Personnel.new(
          name: ws[r, 1],
          start_date: Date.parse(ws[r, 2]),
          end_date: Date.parse(ws[r, 3]),
          description: ws[r, 4]
        )        
        if personnel.within?(date)
          personnels[0].append(personnel)
        end
        if personnel.within?(date + 1)
          personnels[1].append(personnel)
        end          
      rescue Exception => e
        p "attendance_bot[#{personnel.name}]: #{e.message}"
      ensure
        r = r + 1
      end
    end
    personnels
  end
  
  def on_leave_message(today_personnels, tomorrow_personnels, date)
    message = personnels_message("Hi everyone, today (#{date.strftime('%d %b %Y')}) ", today_personnels)
    message += personnels_message("\nTomorrow (#{(date+1).strftime('%d %b %Y')}) ", tomorrow_personnels)
    message
  end
  
  def personnels_message(text, personnels)
    message = text
    if personnels.count == 0
      message += "no one is out-of-office.\n"
    else
      message += "the following personnel are out-of-office:\n"
      personnels.each_with_index do |personnel, index|
        message += "#{index+1}. #{personnel.name}"
        if !personnel.description.blank?
          message += ": #{personnel.description}"
        end
        message += "\n"
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
