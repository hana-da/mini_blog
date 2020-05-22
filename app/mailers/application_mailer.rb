# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('DEFAULT_MAIL_FROM', 'no-reply@example.jp')
  layout 'mailer'
end
