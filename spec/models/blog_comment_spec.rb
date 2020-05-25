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

  describe '.create_with_notification' do
    it 'コメントしたBlogの投稿者がemailを登録していれば通知メールが送信される' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)
      attributes_for_blog_comment = FactoryBot.attributes_for(
        :blog_comment,
        user_id: user.id, blog_id: blog.id
      )

      expect(blog.user.email).to be_present
      expect(BlogComment.create_with_notification(attributes_for_blog_comment))
        .to be_instance_of(BlogComment)
        .and be_valid
        .and be_persisted

      expect { BlogComment.create_with_notification(attributes_for_blog_comment) }
        .to(
          change(BlogComment, :count).by(1)
            .and(change { ActionMailer::Base.deliveries.count }.by(1))
        )

      expect(ActionMailer::Base.deliveries.last.to).to eq([blog.user.email])
    end

    it 'コメントしたBlogの投稿者がemailを登録していないと通知メールは送信されない' do
      user = FactoryBot.create(:user)
      non_email_user = FactoryBot.build(:user, email: '').tap { |u| u.save!(validate: false) }
      non_email_user_blog = FactoryBot.create(:blog, user: non_email_user)
      attributes_for_blog_comment = FactoryBot.attributes_for(
        :blog_comment,
        user_id: user.id, blog_id: non_email_user_blog.id
      )

      expect(non_email_user_blog.user.email).to be_blank
      expect(BlogComment.create_with_notification(attributes_for_blog_comment))
        .to be_instance_of(BlogComment)
        .and be_valid
        .and be_persisted

      expect { BlogComment.create_with_notification(attributes_for_blog_comment) }
        .to(
          change(BlogComment, :count).by(1)
            .and(change { ActionMailer::Base.deliveries.count }.by(0))
        )
    end
  end

  context 'コメントの追加に失敗した時' do
    it '通知メールは送信されない' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)
      attributes_for_blog_comment = FactoryBot.attributes_for(
        :blog_comment,
        user_id: user.id, blog_id: blog.id, content: nil
      )

      expect(blog.user.email).to be_present
      expect(BlogComment.create_with_notification(attributes_for_blog_comment))
        .to be_instance_of(BlogComment)
        .and be_invalid
        .and be_new_record

      expect { BlogComment.create_with_notification(attributes_for_blog_comment) }
        .to(
          change(BlogComment, :count).by(0)
            .and(change { ActionMailer::Base.deliveries.count }.by(0))
        )
    end
  end
end
