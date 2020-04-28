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
class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, authentication_keys: [:username]

  validates :username, uniqueness: true
  validates :username, length: { in: 1..20 }
  validates :username, format: { with: /\A[a-zA-Z]+\z/ }, allow_blank: true
  validates :password, confirmation: true
  validates :password, presence: true, on: :create
  validates :profile, length: { maximum: 200 }
end
