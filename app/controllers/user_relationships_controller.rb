# frozen_string_literal: true

class UserRelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @followed_user = User.find(params[:followed_id])
    current_user.follow!(@followed_user)

    render('mini_blog/reload_follow_unfollow_button')
  end

  def destroy
    @followed_user = User.find(params[:followed_id])
    current_user.unfollow!(@followed_user)

    render('mini_blog/reload_follow_unfollow_button')
  end
end
