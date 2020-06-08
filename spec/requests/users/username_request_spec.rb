# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/:username', type: :request do
  context 'ログインしていない時' do
    it 'ユーザーの公開情報が見える' do
      user = FactoryBot.create(:user)

      get user_path(user)
      expect(response).to have_http_status(:ok)
    end
  end
end
