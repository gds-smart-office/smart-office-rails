require 'test_helper'

class TelegramControllerTest < ActionController::TestCase
  test "should get pong" do
    get :pong
    assert_response :success
  end

  test "should get recep" do
    get :recep
    assert_response :success
  end

end
