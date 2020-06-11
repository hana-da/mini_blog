# frozen_string_literal: true

class MiniBlogController < ApplicationController
  # 全体タイムライン
  def root
    @blogs = Blog.order(created_at: :desc).preload(:user, :liked_users, comments: [:user])
  end
end
