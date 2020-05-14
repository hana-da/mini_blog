# frozen_string_literal: true

# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  content    :text             not null
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
  validates :content, length: { in: 1..140 }

  belongs_to :user

  # attributesの指定があれば new した後にvalidateもする
  #
  # @param [Hash] attributes
  # @return [Blog]
  def self.new_with_validation(attributes = {}, &block)
    new(attributes, &block).tap { |blog| blog.validate if attributes.values.any? }
  end
end
