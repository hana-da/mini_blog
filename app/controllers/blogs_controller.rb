# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    @blog = current_user.blogs.create(params.require(:blog).permit(:content, :image))

    redirect_back(fallback_location: root_path) if @blog.persisted?
  end
end
