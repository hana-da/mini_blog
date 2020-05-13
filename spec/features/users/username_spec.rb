# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/:username', type: :feature do
  it '公開情報が表示されている' do
    user = FactoryBot.create(:user)

    visit user_path(user)

    within('.users__profile') do
      expect(page).to have_css('.users__profile-username', text: user.username)
      expect(page).to have_css('.users__profile-profile',  text: user.profile)
      expect(page).to have_css('.users__profile-blog_url', text: user.blog_url)

      expect(page).to have_link(user.blog_url, href: user.blog_url)
    end
  end

  it 'フォロー中とフォロワーの数が表示されている' do
    user = FactoryBot.create(:user)
    FactoryBot.create_list(:user_relationship, 3, follower: user)
    FactoryBot.create_list(:user_relationship, 2, followed: user)

    visit user_path(user)

    expect(page).to have_css('.users__following-count', text: 3)
    expect(page).to have_css('.users__followers-count', text: 2)
  end

  it '存在しないusernameを指定するとActiveRecord::RecordNotFoundが発生する' do
    expect(User.find_by(username: :not_exist)).to be_nil

    expect { visit user_path(:not_exist) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'navbarのbrandからroot-pathへ戻る事ができる' do
    user = FactoryBot.create(:user)

    visit user_path(user)

    within('nav.navbar') do
      click_link('MiniBlog')
    end

    expect(page).to have_current_path(root_path)
  end
end
