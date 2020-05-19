# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: :show

  def show
    @user = User.find_by!(username: params[:username])
  end

  def follow
    current_user.follow(User.find(params[:id]))
    redirect_back fallback_location: root_path
  end

  def unfollow
    current_user.unfollow(User.find(params[:id]))
    redirect_back fallback_location: root_path
  end

  # ユーザ個別のタイムライン
  def timeline
    @blog = Blog.new_with_validation(content: session[:nil_or_invalid_blog_content])
    session[:nil_or_invalid_blog_content] = nil

    @blogs = current_user.following_blogs.order(created_at: :desc).includes(:user, :liked_users)

    render template: 'mini_blog/root'
  end
end
