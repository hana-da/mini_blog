# frozen_string_literal: true

# == Schema Information
#
# Table name: blog_comments
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  blog_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_blog_comments_on_blog_id  (blog_id)
#  index_blog_comments_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (blog_id => blogs.id)
#  fk_rails_...  (user_id => users.id)
#
class BlogComment < ApplicationRecord
  belongs_to :blog
  belongs_to :user

  validates :content, length: { in: 1..140 }

  def self.create_with_notification(attributes = nil, &block)
    create(attributes, &block).tap do |comment|
      if comment.persisted? && comment.blog.user.email.present? # rubocop:disable Style/IfUnlessModifier
        NotificationMailer.added_to_blog(comment).deliver_now
      end
    end
  end
end
