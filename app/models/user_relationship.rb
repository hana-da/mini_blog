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
class UserRelationship < ApplicationRecord
  belongs_to :followed, class_name: 'User'
  belongs_to :follower, class_name: 'User'

  validate :not_following_myself
  validates :followed_id, uniqueness: { scope: :follower_id }
  validates :follower_id, uniqueness: { scope: :followed_id }

  private def not_following_myself
    return unless [follower_id, followed_id].all?
    return unless follower_id == followed_id

    errors.add(:base, :not_following_myself)
  end
end
