# frozen_string_literal: true

class ReportMailer < ApplicationMailer
  # @param [ActiveSupport::TimeWithZone] on 集計対象日
  # @param [Integer] limit 件数制限
  def daily_favorite_ranking(on:, limit: 10)
    @date = on.to_date
    @ranking = UserFavoriteBlog.count_by_blog(on: @date, limit: limit)

    mail(
      to:      ENV.fetch('REPORT_MAIL_TO'),
      subject: t('.subject', on: @date)
    )
  end
end
