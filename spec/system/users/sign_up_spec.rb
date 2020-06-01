# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/sign_up', type: :system do
  it 'new_user_registration_pathの登録フォームで登録できる' do
    user = FactoryBot.build(:user)
    expect(User.find_by(username: user.username)).to be_nil

    visit new_user_registration_path

    within('#new_user') do
      fill_in('user[username]',              with: user.username)
      fill_in('user[email]',                 with: user.email)
      fill_in('user[password]',              with: 'password')
      fill_in('user[password_confirmation]', with: 'password')
      fill_in('user[profile]',               with: user.profile)
      fill_in('user[blog_url]',              with: user.blog_url)

      click_button
    end

    expect(User.find_by(username: user.username)).not_to be_nil
  end

  describe 'validationに失敗した際のエラーメッセージの表示' do
    context '確認用パスワード以外が違反している時' do
      it 'それぞれの欄にメッセージが出る' do
        user = User.new(username:              '',
                        password:              '',
                        password_confirmation: '',
                        profile:               'too long profile' * 15,
                        blog_url:              '').tap(&:validate)

        visit new_user_registration_path

        within('#new_user') do
          fill_in('user[password]',              with: user.password)
          fill_in('user[password_confirmation]', with: user.password_confirmation)
          fill_in('user[profile]',               with: user.profile)

          click_button
        end

        expect(page).to have_css('.field_with_errors', count: 8) # label もあるので項目数の2倍

        expect(page).to have_css('.form-group__sign_up-username > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-username > .invalid-feedback',
                                 text: user.errors.full_messages_for(:username).join)
        expect(page).to have_css('.form-group__sign_up-email > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-email > .invalid-feedback',
                                 text: user.errors.full_messages_for(:email).join)
        expect(page).to have_css('.form-group__sign_up-password > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-password > .invalid-feedback',
                                 text: user.errors.full_messages_for(:password).join)
        expect(page).to have_css('.form-group__sign_up-profile > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-profile > .invalid-feedback',
                                 text: user.errors.full_messages_for(:profile).join)
      end
    end

    context '確認用パスワードが違反している時' do
      it 'パスワードの欄にもメッセージが出る' do
        user = User.new(password:              'aaa',
                        password_confirmation: 'AAA').tap(&:validate)

        visit new_user_registration_path

        within('#new_user') do
          fill_in('user[password]',              with: user.password)
          fill_in('user[password_confirmation]', with: user.password_confirmation)

          click_button
        end

        expect(page).to have_css('.form-group__sign_up-password > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-password > .invalid-feedback',
                                 text: user.errors.full_messages_for(:password_confirmation).join)
        expect(page).to have_css('.form-group__sign_up-password_confirmation > .field_with_errors')
        expect(page).to have_css('.form-group__sign_up-password_confirmation > .invalid-feedback',
                                 text: user.errors.full_messages_for(:password_confirmation).join)
      end
    end
  end
end
