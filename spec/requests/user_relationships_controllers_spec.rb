# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserRelationshipsControllers', type: :request do
  let!(:user)       { FactoryBot.create(:user) }
  let!(:other_user) { FactoryBot.create(:user) }

  context 'ログインしている時' do
    before { sign_in user }

    it 'フォローできる' do
      expect(user).not_to be_following(other_user)

      expect do
        post user_relationship_path, params: { followed_id: other_user.id }
      end.to change(UserRelationship, :count).by(1)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(root_path)
    end
  end

  context 'ログインしていない時' do
    it 'フォローできない' do
      expect(user).not_to be_following(other_user)

      expect do
        post user_relationship_path, params: { followed_id: other_user.id }
      end.not_to change(UserRelationship, :count)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
