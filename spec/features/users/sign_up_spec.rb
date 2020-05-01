# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/sign_up', type: :feature do
  let(:user) { FactoryBot.build(:user) }

  before do
    expect(User.find_by(username: user.username)).to be_nil
  end

  it 'new_user_registration_pathの登録フォームで登録できる' do
    visit new_user_registration_path

    within('#new_user') do
      fill_in('user[username]',              with: user.username)
      fill_in('user[password]',              with: 'password')
      fill_in('user[password_confirmation]', with: 'password')
      fill_in('user[profile]',               with: user.profile)
      fill_in('user[blog_url]',              with: user.blog_url)

      click_button
    end

    expect(User.find_by(username: user.username)).not_to be_nil
  end
end
