# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/:username', type: :system do
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

  context 'ログインしていない時' do
    it 'フォローする/フォロー解除のボタンは表示されてない' do
      user = FactoryBot.create(:user)

      visit user_path(user)

      expect(page).not_to have_button(t('helpers.submit.follow'))
      expect(page).not_to have_button(t('helpers.submit.unfollow'))
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    context 'フォローしているユーザのページだと', js: true do
      it 'フォロー解除ボタンが表示されていて、押すとフォロー解除できる' do
        following = FactoryBot.create(:user).tap { |u| user.follow!(u) }
        expect(user).to be_following(following)

        visit user_path(following)
        expect(page).not_to have_button(t('helpers.submit.follow'))

        click_button(t('helpers.submit.unfollow'))
        expect(page).to have_button(t('helpers.submit.follow'))

        user.reload

        expect(user).not_to be_following(following)
        expect(page).to have_current_path(user_path(following))
      end
    end

    context 'フォローしていないユーザのページだと' do
      it 'フォローするボタンが表示されていて、押すとフォローできる', js: true do
        not_following = FactoryBot.create(:user)
        expect(user).not_to be_following(not_following)

        visit user_path(not_following)
        expect(page).not_to have_button(t('helpers.submit.unfollow'))

        click_button(t('helpers.submit.follow'))
        expect(page).to have_button(t('helpers.submit.unfollow'))

        user.reload

        expect(user).to be_following(not_following)
        expect(page).to have_current_path(user_path(not_following))
      end
    end

    context '自分自身のページだと' do
      it 'フォローする/フォロー解除のボタンは表示されてない' do
        visit user_path(user)

        expect(page).not_to have_button(t('helpers.submit.follow'))
        expect(page).not_to have_button(t('helpers.submit.unfollow'))
      end
    end
  end
end
