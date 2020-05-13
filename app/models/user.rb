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

  has_many :blogs, dependent: :destroy
  has_many :following_relationships, class_name: 'UserRelationship',
                                     foreign_key: :follower_id, inverse_of: :follower, dependent: :destroy
  has_many :follower_relationships,  class_name: 'UserRelationship',
                                     foreign_key: :followed_id, inverse_of: :followed, dependent: :destroy
  has_many :followers, through: :follower_relationships,  source: :follower
  has_many :following, through: :following_relationships, source: :followed

  # @return [String]
  def to_param
    username
  end

  # userをフォローする
  #
  # @param [User] user フォローするUser
  # @return [User::ActiveRecord_Associations_CollectionProxy]
  def follow(user)
    following << user
  end

  # 自分とフォローしている人のBlogを返す
  #
  # @return [Blog::ActiveRecord_Relation]
  def following_blogs
    Blog.where(user_id: [id, following_ids].flatten!).includes(:user)
  end

  # userをフォローしているか?
  #
  # @param [User, Integer] user_or_id フォローしているか調べるUserかUser#id
  # @return [Boolean]
  def following?(user_or_id)
    user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id
    following.exists?(user_id)
  end

  # userをフォロー解除する
  #
  # @param [User] user フォロー解除するUser
  # @return [UserRelationship, nil] そもそもフォローしていなかった場合はnil
  def unfollow(user)
    following_relationships.find_by(followed: user)&.destroy
  end
end
