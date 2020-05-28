# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportMailer, type: :mailer do
  describe '#daily_favorite_ranking' do
    it do
      FactoryBot.create(:user_favorite_blog)

      period = 1.day.ago
      date = period.to_date

      mail = ReportMailer.daily_favorite_ranking(period: period)

      expect(mail).to be_multipart
      expect(mail.subject).to eq(t('report_mailer.daily_favorite_ranking.subject', period: date))
      expect(mail.from).to eq(['no-reply@example.jp'])
      expect(mail.to).to eq([ENV['REPORT_MAIL_TO']])
    end
  end
end
