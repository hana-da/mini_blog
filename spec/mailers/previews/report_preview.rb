# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/report
class ReportPreview < ActionMailer::Preview
  def daily_favorite_ranking_of_today
    ReportMailer.daily_favorite_ranking(period: Time.zone.today)
  end

  def daily_favorite_ranking_of_yesterday
    ReportMailer.daily_favorite_ranking(period: 1.day.ago)
  end
end
