# frozen_string_literal: true

class MiniBlogController < ApplicationController
  def root
    @blog = Blog.new_with_validation(content: session[:nil_or_invalid_blog_content])
    session[:nil_or_invalid_blog_content] = nil

    @following_ids = current_user&.following_ids
    @blogs = Blog.order(created_at: :desc).includes(:user)
  end
end
