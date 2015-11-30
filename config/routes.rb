Rails.application.routes.draw do
  get 'register/index'
  get 'register/register'

  root 'message#index'
end
