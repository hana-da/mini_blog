# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UsersControllers', type: :request do
  let!(:user) { FactoryBot.create(:user) }

  context 'ログインしている時' do
    before { sign_in user }

    describe '#timeline' do
      it 'current_userのタイムラインが表示される' do
        get timeline_current_user_path

        expect(response).to have_http_status(:ok)
      end
    end
  end

  context 'ログインしていない時' do
    it 'ログイン画面にリダイレクトされる' do
      get timeline_current_user_path

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
