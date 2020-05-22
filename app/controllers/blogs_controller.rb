# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    blog = current_user.blogs.create(params.require(:blog).permit(:content))
    session[:nil_or_invalid_blog_content] = blog.content if blog.invalid?
    redirect_back fallback_location: root_path
  end

  # Blogを「いいね」する
  def like
    blog = Blog.find(params[:id])
    current_user.like!(blog)
    redirect_back fallback_location: root_path
  end

  # Blogにコメントする
  def comment
    comment = Blog.find(params[:id]).comments.create(content: params[:comment], user: current_user)

    send_notification_to_blog_author(comment)
    redirect_back fallback_location: root_path
  end

  private def send_notification_to_blog_author(comment)
    return unless comment.persisted?
    return if comment.blog.user.email.blank?

    NotificationMailer.added_to_blog(comment).deliver_now
  end
end
