# frozen_string_literal: true

class UsersController < ApplicationController
  def show
    @user = User.find_by(username: params[:username]) || raise(ActiveRecord::RecordNotFound)
  end

  def follow
    current_user.follow(User.find(params[:id]))
    redirect_to root_path
  end

  def unfollow
    current_user.unfollow(User.find(params[:id]))
    redirect_to root_path
  end
end
