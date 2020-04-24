# frozen_string_literal: true

Rails.application.routes.draw do
  resources :blogs, only: :create

  root 'mini_blog#root'
end
