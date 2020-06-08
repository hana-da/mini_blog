# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'BlogCommentsControllers', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  context 'ログインしている時' do
    before { sign_in user }

    it 'コメントできる' do
      blog = FactoryBot.create(:blog)

      expect do
        post blog_comment_path(blog), params: { comment: FactoryBot.attributes_for(:blog_comment)[:content] }
      end.to change(BlogComment, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'ログインしていない時' do
    it 'ログイン画面にリダイレクトされる' do
      blog = FactoryBot.create(:blog)

      expect do
        post blog_comment_path(blog), params: { comment: FactoryBot.attributes_for(:blog_comment)[:content] }
      end.not_to change(BlogComment, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
