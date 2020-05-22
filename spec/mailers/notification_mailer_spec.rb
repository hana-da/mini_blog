# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationMailer, type: :mailer do
  describe '#commented_on' do
    it do
      comment = FactoryBot.create(:blog_comment)
      mail = NotificationMailer.added_to_blog(comment)

      expect(mail).to be_multipart
      expect(mail.subject).to eq(t('notification_mailer.added_to_blog.subject'))
      expect(mail.from).to eq(['no-reply@example.jp'])
      expect(mail.to).to eq([comment.blog.user.email])
    end
  end
end
