# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/blogs/:blog_id/like', type: :request do
  context 'ログインしていない時' do
    it '「いいね」はできない' do
      blog = FactoryBot.create(:blog)

      expect do
        post blog_like_path(blog)
      end.not_to change(UserFavoriteBlog, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    it '「いいね」できる' do
      blog = FactoryBot.create(:blog)

      expect do
        post blog_like_path(blog), xhr: true
      end.to change(UserFavoriteBlog, :count).by(1)

      expect(response).to have_http_status(:ok)
    end

    context 'xhrでない場合は' do
      it do
        blog = FactoryBot.create(:blog)

        expect do
          post blog_like_path(blog)
        end.to raise_error(ActionView::MissingTemplate)
      end
    end

    it '既に「いいね」したblogには「いいね」できない' do
      favorite = FactoryBot.create(:user_favorite_blog, user: user)
      favorited_blog = favorite.blog

      expect do
        post blog_like_path(favorited_blog)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect(UserFavoriteBlog.count).to eq(1)
    end

    it '自分の投稿には「いいね」できない' do
      blog = FactoryBot.create(:blog, user: user)

      expect do
        post blog_like_path(blog)
      end.to raise_error(ActiveRecord::RecordInvalid)
      expect(UserFavoriteBlog.count).to be_zero
    end
  end
end
