# frozen_string_literal: true

Rails.application.routes.draw do
  resources :blogs, only: :create

  devise_for :users, skip: :registration
  devise_scope :user do
    get  '/users/sign_up(.:format)', to: 'devise/registrations#new',    as: 'new_user_registration'
    post '/users(.:format)',         to: 'devise/registrations#create', as: 'user_registration'
  end
  get 'users/:username', to: 'users#show', as: :user

  root 'mini_blog#root'
end
