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
end
