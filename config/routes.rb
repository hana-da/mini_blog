# frozen_string_literal: true

Rails.application.routes.draw do
  resources :blogs, only: :create do
    resource :comment, only: :create, controller: :blog_comments
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

  resource :current_user, only: [], path: :user, controller: :users do
    resource :relationship, only: %i[create destroy], controller: :user_relationships
    member do
      get :timeline
    end
  end

  root 'mini_blog#root'
end
