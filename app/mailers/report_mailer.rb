# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # @param [ActiveSupport::TimeWithZone] period 集計対象日
  # @param [Integer] limit 件数制限
  def daily_favorite_ranking(period:, limit: 10)
    @date = period.to_date
    @ranking = UserFavoriteBlog.count_by_blog(on: period, limit: limit)

    mail(
      to:      ENV.fetch('REPORT_MAIL_TO'),
      subject: t('.subject', period: @date)
    )
  end
end
