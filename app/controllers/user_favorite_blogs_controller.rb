# frozen_string_literal: true

class UserFavoriteBlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    @blog = Blog.find(params[:blog_id])
    current_user.like!(@blog)

    render('mini_blog/reload_blog_card')
  end
end
