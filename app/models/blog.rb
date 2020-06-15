# frozen_string_literal: true

# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           default(0), not null
#
# Indexes
#
#  index_blogs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Blog < ApplicationRecord
  after_validation :modify_errors_message_for_image

  belongs_to :user

  has_many :comments, class_name: 'BlogComment', dependent: :destroy
  has_many :likes, class_name: 'UserFavoriteBlog', dependent: :destroy

  has_many :liked_users, through: :likes, source: :user

  mount_uploader :image, BlogImageUploader

  validates :content, length: { in: 1..140 }

  scope :for_timeline, -> { order(created_at: :desc).preload(:user, :liked_users, comments: [:user]) }

  private def modify_errors_message_for_image
    return unless errors.include?(:image)

    errors.delete(:image)
    errors.add(:image, errors.generate_message(:image, :content_type_whitelist_error))
  end
end
