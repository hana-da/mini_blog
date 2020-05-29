# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: :show

  def show
    @user = User.find_by!(username: params[:username])
  end

  def follow
    current_user.follow!(User.find(params[:id]))
    redirect_back fallback_location: root_path
  end

  def unfollow
    current_user.unfollow(User.find(params[:id]))
    redirect_back fallback_location: root_path
  end

  # ユーザ個別のタイムライン
  def timeline
    @blog = blog_for_form
    session[:nil_or_invalid_blog_content] = nil
    session[:blog_image_error] = nil

    @blogs = current_user.following_blogs.order(created_at: :desc).preload(:user, :liked_users, comments: [:user])

    render template: 'mini_blog/root'
  end

  private def blog_for_form
    Blog.new_with_validation(content: session[:nil_or_invalid_blog_content]).tap do |blog|
      if session[:blog_image_error]
        blog.errors.add(:image, blog.errors.generate_message(:image, :content_type_whitelist_error))
      end
    end
  end
end
