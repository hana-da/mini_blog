# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    Blog.new(params.require(:blog).permit(:content)).save
    redirect_to root_path
  end
end
