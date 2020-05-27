# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # @param [ActiveSupport::TimeWithZone] period 集計対象日
  # @param [Integer] 件数制限
  def daily_favorite_ranking(period:, limit: 10)
    @date = period.to_date
    @ranking = UserFavoriteBlog.daily_ranking(period: period, limit: limit)

    mail(
      to:      ENV.fetch('REPORT_MAIL_TO'),
      subject: "[MiniBlog] #{t('.favorite_ranking', period: @date)}"
    )
  end
end
