# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    blog = current_user.blogs.create(params.require(:blog).permit(:content))
    session[:invalid_blog_content] = blog.content if blog.invalid?
    redirect_back fallback_location: root_path
  end
end
