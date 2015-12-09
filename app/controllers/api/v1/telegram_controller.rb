# require "#{Rails.root}/app/helpers/telegram_bot_helper"

class Api::V1::TelegramController < Api::ApiController
  include TelegramBotHelper

  before_action :api_authenticate

  def initialize
    @pong_ip =            ENV["pong_ip"]
    @recep_ip =           ENV["recep_ip"]
    @telegram_bot_token = ENV["telegram_bot_token"]
  end
  
  def api_pong
    user_id = params[:user_id]
    chat_id = params[:chat_id]
    caption = params[:caption]
    
    Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
      code = pong(bot, user_id, chat_id, caption.nil?? {} : {caption: caption})
      render_response(code)
    end
  end

  def api_recep
    user_id = params[:user_id]
    chat_id = params[:chat_id]
    caption = params[:caption]

    Telegram::Bot::Client.run(@telegram_bot_token) do |bot|
      code = recep(bot, user_id, chat_id, caption.nil?? {} : {caption: caption})
      render_response(code)
    end
  end
  
  def render_response(code)
    case code
      when :success
        render :json => {:status => "success"}
      when :error
        render :json => {:status => "error"}
      when :unauthorized
        render :json => {:status => "unauthorized"}
    end
  end
end