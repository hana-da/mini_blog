# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BlogsControllers', type: :request do
  context 'ログインしている時' do
    before do
      sign_in FactoryBot.create(:user)
    end

    it 'blogを投稿できる' do
      expect do
        post blogs_path, params: { blog: FactoryBot.attributes_for(:blog) }
      end.to change(Blog, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'ログインしていない時' do
    it 'blogは投稿できない' do
      expect do
        post blogs_path, params: { blog: FactoryBot.attributes_for(:blog) }
      end.not_to change(Blog, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe '#like' do
    context 'ログインしていない時' do
      it '「いいね」はできない' do
        blog = FactoryBot.create(:blog)

        expect do
          post like_blog_path(blog)
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

      it '既に「いいね」したblogには「いいね」できない' do
        favorite = FactoryBot.create(:user_favorite_blog, user: user)
        favorited_blog = favorite.blog

        expect do
          post like_blog_path(favorited_blog)
        end.to raise_error(ActiveRecord::RecordInvalid)
        expect(UserFavoriteBlog.count).to eq(1)
      end

      it '自分の投稿には「いいね」できない' do
        blog = FactoryBot.create(:blog, user: user)

        expect do
          post like_blog_path(blog)
        end.to raise_error(ActiveRecord::RecordInvalid)
        expect(UserFavoriteBlog.count).to be_zero
      end
    end
  end
end
