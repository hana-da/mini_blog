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
require 'rails_helper'

RSpec.describe UserFavoriteBlog, type: :model do
  describe 'validations' do
    it do
      favorite = FactoryBot.create(:user_favorite_blog)
      expect(favorite).to validate_uniqueness_of(:blog_id).scoped_to(:user_id)
      expect(favorite).to validate_uniqueness_of(:user_id).scoped_to(:blog_id)
    end

    it '同じ投稿に複数回いいねはできない' do
      favorite = FactoryBot.create(:user_favorite_blog)
      blog = favorite.blog
      user = favorite.user

      expect(UserFavoriteBlog.new(blog: blog, user: user)).to be_invalid
    end
  end

  describe 'associations' do
    it do
      favorite_blog = UserFavoriteBlog.new

      expect(favorite_blog).to belong_to(:user)
      expect(favorite_blog).to belong_to(:blog)
    end
  end
end
