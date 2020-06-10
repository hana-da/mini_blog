# frozen_string_literal: true

class UserRelationshipsController < ApplicationController
  before_action :authenticate_user!

  def create
    current_user.follow!(User.find(params[:followed_id]))
    redirect_back fallback_location: root_path
  end

  def destroy
    current_user.unfollow!(User.find(params[:followed_id]))
    redirect_back fallback_location: root_path
  end
end
