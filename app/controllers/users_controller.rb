# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: :show

  def show
    @user = User.find_by!(username: params[:username])
  end

  # ユーザ個別のタイムライン
  def timeline
    @blog = Blog.new
    @blogs = current_user.following_blogs.order(created_at: :desc).preload(:user, :liked_users, comments: [:user])

    render template: 'mini_blog/root'
  end
end
