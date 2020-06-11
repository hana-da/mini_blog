# frozen_string_literal: true

class BlogCommentsController < ApplicationController
  before_action :authenticate_user!

  def create
    @blog = Blog.find(params[:blog_id])
    @comment = @blog.comments
                    .create_with_notification(content: params[:blog_comment][:content], user: current_user)
                    .then { |c| c.new_record? && c }

    render 'mini_blog/reload_blog_card'
  end
end
