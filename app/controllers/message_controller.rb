require 'ext/Date'

class MessageController < ApplicationController
  include MessageHelper
  
  def index
    @chart = chart(Date.today-5, Date.today)
  end
end
