# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: :show

  def show
    @user = User.find_by!(username: params[:username])
  end

  # ユーザ個別のタイムライン
  def timeline
    @blogs = current_user.following_blogs.for_timeline

    render template: 'mini_blog/root'
  end
end
