################################################################################
#
# Application Routes Configuration
#
# Copyright (c) 2019 The MITRE Corporation.  All rights reserved.
#
################################################################################

# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do

  get 'eob/index'
  get 'eob/show'
  #get 'eob/index'
  get 'eob/show',   to: 'eobs#show'
  get 'eobs/index', to: 'eobs#index'
  #get 'eobs/show'
  resources :eobs,            only: [:index, :show]
  resources	:practitioners,		only: [:show]

  get '/home', to: 'home#index'
  get '/dashboard', to: 'dashboard#index'

  root 'welcome#index'
end
