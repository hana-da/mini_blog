# frozen_string_literal: true

FactoryBot.define do
  sequence(:quote_140) { Faker::Quote.most_interesting_man_in_the_world.first(140).strip }
  sequence(:quote_200) { Faker::Quote.matz.first(200).strip }
  sequence(:url) { Faker::Internet.url(host: 'example.jp') }

  sequence(:email) do |n|
    "#{n}_#{Faker::Internet.email(domain: 'example.jp')}"
  end
  sequence(:username) do |n|
    "#{((n % 25) + 'A'.ord).chr}#{Faker::Internet.username(specifier: 1..20).delete('^a-zA-Z')}".truncate(20)
  end
end
