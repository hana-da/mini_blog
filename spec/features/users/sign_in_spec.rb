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
end
