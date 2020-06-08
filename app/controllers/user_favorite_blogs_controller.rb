# frozen_string_literal: true

class UserFavoriteBlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.like!(Blog.find(params[:blog_id]))
    redirect_back fallback_location: root_path
  end
end
