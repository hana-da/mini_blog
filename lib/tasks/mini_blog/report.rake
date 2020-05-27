# frozen_string_literal: true

namespace :mini_blog do
  namespace :report do
    desc 'send email of daily favorite ranking of yesterday'
    task daily_favorite_ranking: :environment do
      ReportMailer.daily_favorite_ranking(period: 1.day.ago).deliver_now
    end
  end
end
