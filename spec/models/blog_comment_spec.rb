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
require 'rails_helper'

RSpec.describe BlogComment, type: :model do
  describe 'validations' do
    it do
      expect(BlogComment.new).to validate_length_of(:content).is_at_least(1).is_at_most(140)
    end
  end

  describe 'associations' do
    it do
      comment = BlogComment.new

      expect(comment).to belong_to(:blog)
      expect(comment).to belong_to(:user)
    end
  end
end
