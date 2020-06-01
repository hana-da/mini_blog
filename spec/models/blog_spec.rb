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
require 'rails_helper'

RSpec.describe Blog, type: :model do
  describe 'validations' do
    it do
      expect(Blog.new).to validate_length_of(:content).is_at_least(1).is_at_most(140)
    end
  end

  describe 'associations' do
    it do
      blog = Blog.new

      expect(blog).to belong_to(:user)
      expect(blog).to have_many(:comments).class_name('BlogComment').dependent(:destroy)

      # いいね
      expect(blog).to have_many(:likes).class_name('UserFavoriteBlog').dependent(:destroy)
      expect(blog).to have_many(:liked_users).through(:likes).source(:user)
    end
  end
end
