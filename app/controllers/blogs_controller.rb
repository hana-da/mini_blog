# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate_user!

  def create
    blog = current_user.blogs.create(params.require(:blog).permit(:content, :image))
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
  #
  # コメントの作成に成功するとBlogの投稿者に通知メールが送信される
  def comment
    Blog.find(params[:id]).comments
        .create_with_notification(content: params[:comment], user: current_user)

    redirect_back fallback_location: root_path
  end
end
