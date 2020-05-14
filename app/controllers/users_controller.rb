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

  def timeline
    @blog = Blog.new do |blog|
      next unless session[:invalid_blog_content]

      blog.content = session[:invalid_blog_content]
      blog.validate
    end
    @blogs = current_user.following_blogs.order(created_at: :desc)
  end
end
