# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  blog_url           :text             default(""), not null
#  encrypted_password :string           default(""), not null
#  profile            :text             default(""), not null
#  username           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it do
      user = User.new
      expect(user).to validate_length_of(:username).is_at_least(1).is_at_most(20)
      expect(user).to validate_uniqueness_of(:username)
      expect(user).to validate_confirmation_of(:password)
      expect(user).to validate_presence_of(:password).on(:create)
      expect(user).to validate_length_of(:profile).is_at_most(200)
    end

    where(:invalid_username) do
      [
        ['sujidame4'],
        ['space dame'],
        ['usernamehanijumojiinainishimasho'],
      ]
    end

    with_them do
      it { expect(User.new).not_to allow_value(invalid_username).for(:username) }
    end

    it 'usernameはcase-sensitive' do
      username = 'someone'
      FactoryBot.create(:user, username: username)
      expect { FactoryBot.create(:user, username: username.upcase) }.not_to raise_error
    end
  end

  describe 'associations' do
    it do
      expect(User.new).to have_many(:blogs).dependent(:destroy)
    end
  end
end
