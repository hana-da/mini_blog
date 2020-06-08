# frozen_string_literal: true

class BlogCommentsController < ApplicationController
  before_action :authenticate_user!

  # TODO: エラー処理
  def create
    Blog.find(params[:blog_id]).comments
        .create_with_notification(content: params[:comment], user: current_user)

    redirect_back fallback_location: root_path
  end
end
