Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :eobs,            only: [:index, :show]
  resources	:practitioners,		only: [:show]

  get '/home', to: 'welcome#index'
  get '/dashboard', to: 'dashboard#index'
  get '/login', to: 'dashboard#login'
  get '/launch', to: 'dashboard#launch'
  delete '/disconnect', to: 'dashboard#disconnect'
  root 'dashboard#launch'
end
