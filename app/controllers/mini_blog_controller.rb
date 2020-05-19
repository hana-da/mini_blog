# frozen_string_literal: true

class MiniBlogController < ApplicationController
  # 全体タイムライン
  def root
    @blog = Blog.new_with_validation(content: session[:nil_or_invalid_blog_content])
    session[:nil_or_invalid_blog_content] = nil

    @blogs = Blog.order(created_at: :desc).includes(:user, :liked_users)
  end
end
