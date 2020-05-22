# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/notification
class NotificationPreview < ActionMailer::Preview
  def when_comment_added_to_blog
    comment = BlogComment.first || FactoryBot.create(:blog_comment)
    NotificationMailer.added_to_blog(comment)
  end
end
