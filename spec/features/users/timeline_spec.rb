# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/timeline', type: :feature do
  context 'ログインしていない時' do
    it 'ログインを求められる' do
      visit user_timeline_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    it '自分とフォローしているユーザの投稿のみが表示される' do
      following_user = FactoryBot.create(:user).tap { |u| user.follow(u) }
      other_user = FactoryBot.create(:user)

      expect(user.following).to include(following_user)
      expect(user.following).not_to include(other_user)

      user_blog = FactoryBot.create(:blog, user: user)
      following_blog = FactoryBot.create(:blog, user: following_user)
      other_blog = FactoryBot.create(:blog, user: other_user)

      visit user_timeline_path

      expect(page).to have_css("li#blog-#{user_blog.id}")
      expect(page).to have_css("li#blog-#{following_blog.id}")
      expect(page).not_to have_css("li#blog-#{other_blog.id}")
    end
  end
end
