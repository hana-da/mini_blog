# frozen_string_literal: true

# == Schema Information
#
# Table name: user_relationships
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  followed_id :bigint           not null
#  follower_id :bigint           not null
#
# Indexes
#
#  index_user_relationships_on_followed_id                  (followed_id)
#  index_user_relationships_on_follower_id                  (follower_id)
#  index_user_relationships_on_follower_id_and_followed_id  (follower_id,followed_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (followed_id => users.id)
#  fk_rails_...  (follower_id => users.id)
#
require 'rails_helper'

RSpec.describe UserRelationship, type: :model do
  describe 'validations' do
    it do
      relationship = FactoryBot.create(:user_relationship)
      expect(relationship).to validate_uniqueness_of(:followed_id).scoped_to(:follower_id)
      expect(relationship).to validate_uniqueness_of(:follower_id).scoped_to(:followed_id)
    end

    it '自分自身をフォローする事はできない' do
      user = FactoryBot.create(:user)
      expect(UserRelationship.new(followed: user, follower: user)).to be_invalid
    end
  end

  describe 'associations' do
    it do
      relationship = UserRelationship.new
      expect(relationship).to belong_to(:followed).class_name('User')
      expect(relationship).to belong_to(:follower).class_name('User')
    end
  end
end
