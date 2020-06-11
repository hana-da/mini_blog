# frozen_string_literal: true

class BlogCommentsController < ApplicationController
  before_action :authenticate_user!

  # TODO: エラー処理
  def create
    @blog = Blog.find(params[:blog_id])
    @blog.comments
         .create_with_notification(content: params[:blog_comment][:content], user: current_user)

    render 'mini_blog/reload_blog_card'
  end
end
