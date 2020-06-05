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
    get  '/users/sign_up', to: 'devise/registrations#new',    as: 'new_user_registration'
    post '/users',         to: 'devise/registrations#create', as: 'user_registration'
  end

  resources :users, only: :show, param: :username

  resource :user, only: [] do
    resource :relationship, only: %i[create], controller: :user_relationships
    member do
      get :timeline

      post :unfollow
    end
  end

  root 'mini_blog#root'
end
