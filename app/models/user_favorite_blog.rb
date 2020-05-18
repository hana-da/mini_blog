# frozen_string_literal: true

# == Schema Information
#
# Table name: user_favorite_blogs
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  blog_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_user_favorite_blogs_on_blog_id              (blog_id)
#  index_user_favorite_blogs_on_blog_id_and_user_id  (blog_id,user_id) UNIQUE
#  index_user_favorite_blogs_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (blog_id => blogs.id)
#  fk_rails_...  (user_id => users.id)
#
class UserFavoriteBlog < ApplicationRecord
  belongs_to :blog
  belongs_to :user

  validate :not_own_blog
  validates :blog_id, uniqueness: { scope: :user_id }
  validates :user_id, uniqueness: { scope: :blog_id }

  private def not_own_blog
    return unless blog&.user_id == user_id

    errors.add(:base, :not_own_blog)
  end
end
