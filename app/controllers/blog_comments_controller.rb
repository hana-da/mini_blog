# frozen_string_literal: true

class BlogCommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @blog = Blog.find(params[:blog_id])
    @comment = current_user.blog_comments
                           .create_with_notification(blog: @blog, content: params[:blog_comment][:content])
                           .then { |c| c.new_record? && c }

    render 'mini_blog/reload_blog_card'
  end
end
