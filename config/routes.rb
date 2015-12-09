Rails.application.routes.draw do
  namespace :api, :defaults => {:format => :json} do
    namespace :v1 do
      namespace :telegram do
        post :pong, to: :api_pong
        post :recep, to: :api_recep
      end
    end
  end

  root 'message#index'
end
