# frozen_string_literal: true

class MiniBlogController < ApplicationController
  def root
    @blog = Blog.new do |blog|
      next unless session[:invalid_blog_content]

      blog.content = session[:invalid_blog_content]
      blog.validate
    end
    session[:invalid_blog_content] = nil

    @following_ids = current_user&.following_ids
    @blogs = Blog.includes(:user)
  end
end
