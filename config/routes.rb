# frozen_string_literal: true

Rails.application.routes.draw do
  resources :blogs, only: :create do
    member do
      post :like
      post :comment
    end
  end

  devise_for :users, skip: :registration
  devise_scope :user do
    get  '/users/sign_up(.:format)', to: 'devise/registrations#new',    as: 'new_user_registration'
    post '/users(.:format)',         to: 'devise/registrations#create', as: 'user_registration'
  end
  scope :users do
    get  'timeline',  to: 'users#timeline', as: :user_timeline
    get  ':username', to: 'users#show',     as: :user

    post 'follow',    to: 'users#follow',   as: :follow_user
    post 'unfollow',  to: 'users#unfollow', as: :unfollow_user
  end

  root 'mini_blog#root'
end
