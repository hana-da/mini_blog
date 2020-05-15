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

      # いいね
      expect(blog).to have_many(:likes).class_name('UserFavoriteBlog').dependent(:destroy)
      expect(blog).to have_many(:liked_users).through(:likes).source(:user)
    end
  end

  describe '.new_with_validate' do
    context '引数がない時' do
      it 'validationは行われない' do
        blog_without_validation = Blog.new_with_validation

        expect(blog_without_validation).to be_instance_of(Blog)
        expect(blog_without_validation.content).to be_nil
        expect(blog_without_validation.errors).to be_empty
      end
    end

    context '引数なしでblock付きの時' do
      it 'validationは行われない' do
        blog_without_validation = Blog.new_with_validation { |blog| blog.content = '' }

        expect(blog_without_validation).to be_instance_of(Blog)
        expect(blog_without_validation.content).to eq('')
        expect(blog_without_validation.errors).to be_empty
      end
    end

    context '引数の値がnilの時' do
      it 'validationは行われない' do
        blog_without_validation = Blog.new_with_validation(content: nil)

        expect(blog_without_validation).to be_instance_of(Blog)
        expect(blog_without_validation.content).to be_nil
        expect(blog_without_validation.errors).to be_empty
      end
    end

    context '引数の値がnilでない時' do
      it 'validationが行われている' do
        blog_with_validation = Blog.new_with_validation(content: '')

        expect(blog_with_validation).to be_instance_of(Blog)
        expect(blog_with_validation.content).to eq('')
        expect(blog_with_validation.errors).to be_include(:content)
      end
    end
  end
end
