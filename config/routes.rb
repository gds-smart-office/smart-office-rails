Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  devise_for :users
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
