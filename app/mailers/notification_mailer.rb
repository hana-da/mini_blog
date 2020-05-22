# frozen_string_literal: true

class NotificationMailer < ApplicationMailer
  def added_to_blog(comment)
    @comment = comment
    mail(
      to:      @comment.blog.user.email,
      subject: t('.subject')
    )
  end
end
