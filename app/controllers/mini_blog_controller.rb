# frozen_string_literal: true

class MiniBlogController < ApplicationController
  # 全体タイムライン
  def root
    @blog = blog_for_form
    session[:nil_or_invalid_blog_content] = nil
    session[:blog_image_error] = nil

    @blogs = Blog.order(created_at: :desc).preload(:user, :liked_users, comments: [:user])
  end

  private def blog_for_form
    Blog.new_with_validation(content: session[:nil_or_invalid_blog_content]).tap do |blog|
      if session[:blog_image_error]
        blog.errors.add(:image, blog.errors.generate_message(:image, :content_type_whitelist_error))
      end
    end
  end
end
