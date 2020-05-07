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
      user = User.new
      expect(user).to have_many(:blogs).dependent(:destroy)
      # ユーザがフォローしている関係
      expect(user).to have_many(:following_relationships).with_foreign_key(:follower_id)
                                                         .class_name('UserRelationship')
                                                         .inverse_of(:follower)
                                                         .dependent(:destroy)
      # ユーザがフォローされている関係
      expect(user).to have_many(:follower_relationships).with_foreign_key(:followed_id)
                                                        .class_name('UserRelationship')
                                                        .inverse_of(:followed)
                                                        .dependent(:destroy)
      # ユーザのフォロワーのユーザ
      expect(user).to have_many(:followers).through(:follower_relationships).source(:follower)
      # ユーザがフォローしているユーザ
      expect(user).to have_many(:following).through(:following_relationships).source(:followed)
    end

    describe 'user relationship' do
      let(:user_a) { FactoryBot.create(:user) }
      let(:user_b) { FactoryBot.create(:user) }

      context 'user_a のフォロワーに user_b がなった時' do
        before do
          expect(UserRelationship.count).to be_zero

          user_a.followers << user_b
        end

        it 'user_aのフォロワーにuser_bが含まれている' do
          expect(user_a.followers).to be_include(user_b)
        end

        it 'user_bがフォローしているユーザにuser_aが含まれている' do
          expect(user_b.following).to be_include(user_a)
        end
      end

      context 'user_b が user_a をフォローした時' do
        before do
          expect(UserRelationship.count).to be_zero

          user_b.following << user_a
        end

        it 'user_bがフォローしているユーザにuser_aが含まれている' do
          expect(user_b.following).to be_include(user_a)
        end

        it 'user_aのフォロワーにuser_bが含まれている' do
          expect(user_a.followers).to be_include(user_b)
        end
      end
    end
  end
end
