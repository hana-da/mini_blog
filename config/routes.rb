# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :blogs, only: :create

  get 'users/:username', to: 'users#show', as: :user

  root 'mini_blog#root'
end
