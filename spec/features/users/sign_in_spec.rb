# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/sign_in', type: :feature do
  it 'new_user_session_pathのフォームでログインできる' do
    user = FactoryBot.create(:user)

    visit new_user_session_path

    within('#new_user') do
      fill_in('user[username]',              with: user.username)
      fill_in('user[password]',              with: user.password)

      click_button
    end

    expect(page).to have_css(%(a[data-method="delete"][href="#{destroy_user_session_path}"]),
                             text: t('devise.shared.links.sign_out'))
  end

  it '認証に失敗した時はエラーメッセージが表示される' do
    visit new_user_session_path
    expect(page).not_to have_css('.alert-danger')

    within('#new_user') do
      click_button
    end

    expect(page).to have_css('.alert-danger',
                             text: t('devise.failure.not_found_in_database',
                                     authentication_keys: User.human_attribute_name(:username)))
  end
end
