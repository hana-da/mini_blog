# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  blog_url           :text             default(""), not null
#  encrypted_password :string           default(""), not null
#  profile            :text             default(""), not null
#  username           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_username  (username) UNIQUE
#
FactoryBot.define do
  factory :user do
    username { Faker::Internet.username(specifier: 1..20).delete('^a-zA-Z') }
    password { 'password' }
    password_confirmation { 'password' }
  end
end
