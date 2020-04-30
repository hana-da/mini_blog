# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.blogs.create(params.require(:blog).permit(:content))
    redirect_to root_path
  end
end
