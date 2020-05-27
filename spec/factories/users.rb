# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :bigint           not null, primary key
#  blog_url           :text             default(""), not null
#  email              :string           default(""), not null
#  encrypted_password :string           default(""), not null
#  profile            :text             default(""), not null
#  username           :string           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_users_on_email     (email) UNIQUE WHERE ((email)::text <> ''::text)
#  index_users_on_username  (username) UNIQUE
#
FactoryBot.define do
  factory :user do
    blog_url              { generate(:url) }
    email                 { generate(:email) }
    password              { 'password' }
    password_confirmation { 'password' }
    profile               { generate(:quote_200) }
    username              { generate(:username) }
  end
end
