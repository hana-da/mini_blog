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

    it '自分の投稿にいいねする事はできない' do
      blog = FactoryBot.create(:blog)
      blog_user = blog.user

      expect(UserFavoriteBlog.new(blog: blog, user: blog_user)).to be_invalid
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

  describe '.count_by_blog' do
    context '引数がない時' do
      it '本日「いいね」された回数の上位10件が降順で返ってくる' do
        blogs = FactoryBot.create_list(:blog, 11)

        blogs.flat_map.with_index(1) { |b, i| FactoryBot.create_list(:user_favorite_blog, i, blog: b) }

        actual_ranking = UserFavoriteBlog.count_by_blog
        expect(actual_ranking).to be_a(Hash)
        expect(actual_ranking.keys.first).to be_a(Blog)
        expect(actual_ranking.keys.first.association(:user)).to be_loaded
        expect(actual_ranking.size).to eq(10) # 10件だけ
        expect(actual_ranking.values).to eq(actual_ranking.values.sort.reverse) # 降順
      end

      it '今日より前の「いいね」は含まれない' do
        travel_to(2.days.ago) do
          FactoryBot.create(:user_favorite_blog)
        end

        travel_to(Time.zone.now.midnight - 1) do
          FactoryBot.create(:user_favorite_blog)
        end

        # 今日の「いいね」
        blog = FactoryBot.create(:blog)
        FactoryBot.create_list(:user_favorite_blog, 3, blog: blog)

        expect(UserFavoriteBlog.count_by_blog.values.first).to eq(3)
      end
    end

    context '引数で昨日のランキングを指定した時' do
      it '昨日の「いいね」だけが含まれる' do
        # 一昨日の「いいね」
        travel_to(1.day.ago.midnight - 1) do
          FactoryBot.create(:user_favorite_blog)
        end

        # 昨日の「いいね」
        travel_to(1.day.ago) do
          blog = FactoryBot.create(:blog)
          FactoryBot.create_list(:user_favorite_blog, 3, blog: blog)
        end

        # 今日の「いいね」
        travel_to(Time.zone.now.midnight) do
          FactoryBot.create(:user_favorite_blog)
        end

        expect(UserFavoriteBlog.count_by_blog(on: 1.day.ago).values.first).to eq(3)
      end
    end

    context '引数で件数を指定した時' do
      it '指定した件数分だけ返ってくる' do
        FactoryBot.create_list(:user_favorite_blog, 5)

        # この場合は5件とも同率1位だが、limit:3なので神(DB)が選んだ適当な3件が返る
        expect(UserFavoriteBlog.count_by_blog(limit: 3).size).to eq(3)
      end
    end
  end
end
