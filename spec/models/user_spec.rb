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
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it do
      user = User.new
      expect(user).to validate_length_of(:username).is_at_least(1).is_at_most(20)
      expect(user).to validate_uniqueness_of(:username)
      expect(user).not_to allow_values('sujidame4', 'space dame', 'kigo_dame').for(:username)

      expect(user).to validate_presence_of(:email)
      expect(user).to validate_uniqueness_of(:email).case_insensitive
      expect(user).to allow_values('hana-da@example.jp', 'a@a.a').for(:email)
      expect(user).not_to allow_values('hana-da', '.a', 'a.a', '@a', '@.a', '@a.a', 'a@a', 'a@.a').for(:email)

      expect(user).to validate_confirmation_of(:password)
      expect(user).to validate_presence_of(:password).on(:create)

      expect(user).to validate_length_of(:profile).is_at_most(200)
    end

    it 'emailが""なのはuniquenessにはかからない' do
      # emailは仕様変更で増えたのでdefaultの""になっているレコードが存在する場合がある
      old_user = FactoryBot.build(:user, email: '').tap { |u| u.save!(validate: false) }.reload
      expect(old_user).to be_persisted
      expect(old_user.email).to eq('')

      new_user = User.new.tap(&:validate)
      expect(new_user.email).to eq('')

      expect(new_user.errors).not_to be_added(:email, :taken, value: '')
    end
  end

  describe 'associations' do
    it do
      user = User.new
      expect(user).to have_many(:blogs).dependent(:destroy)
      expect(user).to have_many(:blog_comments).dependent(:destroy)

      # ユーザがフォローしている関係
      expect(user).to have_many(:following_relationships).with_foreign_key(:follower_id)
                                                         .class_name('UserRelationship')
                                                         .inverse_of(:follower)
                                                         .dependent(:destroy)
      # ユーザがフォローされている関係
      expect(user).to have_many(:follower_relationships).with_foreign_key(:followed_id)
                                                        .class_name('UserRelationship')
                                                        .inverse_of(:followed)
                                                        .dependent(:destroy)
      # ユーザのフォロワーのユーザ
      expect(user).to have_many(:followers).through(:follower_relationships).source(:follower)
      # ユーザがフォローしているユーザ
      expect(user).to have_many(:following).through(:following_relationships).source(:followed)

      # いいね
      expect(user).to have_many(:likes).class_name('UserFavoriteBlog').dependent(:destroy)
      # いいねしたBlog
      expect(user).to have_many(:likes_blogs).through(:likes).source(:blog)
    end

    describe 'user relationship' do
      let(:user_a) { FactoryBot.create(:user) }
      let(:user_b) { FactoryBot.create(:user) }

      context 'user_a のフォロワーに user_b がなった時' do
        before do
          expect(UserRelationship.count).to be_zero

          user_a.followers << user_b
        end

        it 'user_aのフォロワーにuser_bが含まれている' do
          expect(user_a.followers).to be_include(user_b)
        end

        it 'user_bがフォローしているユーザにuser_aが含まれている' do
          expect(user_b.following).to be_include(user_a)
        end
      end

      context 'user_b が user_a をフォローした時' do
        before do
          expect(UserRelationship.count).to be_zero

          user_b.following << user_a
        end

        it 'user_bがフォローしているユーザにuser_aが含まれている' do
          expect(user_b.following).to be_include(user_a)
        end

        it 'user_aのフォロワーにuser_bが含まれている' do
          expect(user_a.followers).to be_include(user_b)
        end
      end
    end
  end

  describe '#follow!' do
    it 'フォローする事ができる' do
      user_a, user_b = FactoryBot.create_list(:user, 2)

      expect(user_a.following).not_to be_include(user_b)
      expect(user_b.followers).not_to be_include(user_a)

      # フォローする
      user_a.follow!(user_b)

      # user_a からみると user_b はフォローしている人になる
      expect(user_a.following).to be_include(user_b)
      # user_b からみると user_a はフォロワーになる
      expect(user_b.followers).to be_include(user_a)
    end

    it '既にフォローしている人をフォローするとActiveRecord::RecordInvalidが発生する' do
      user_a, user_b = FactoryBot.create_list(:user, 2)
      user_a.follow!(user_b)

      expect { user_a.follow!(user_b) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it '自分自身をフォローする事はできない' do
      user = FactoryBot.create(:user)

      expect { user.follow!(user) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#following_blogs' do
    it '自分とフォローしている人のblogを返す' do
      user = FactoryBot.create(:user)
      following_user = FactoryBot.create(:user).tap { |u| user.follow!(u) }
      other_user = FactoryBot.create(:user)

      expect(user).to be_following(following_user)
      expect(user).not_to be_following(other_user)

      user_blog = FactoryBot.create(:blog, user: user)
      following_blog = FactoryBot.create(:blog, user: following_user)
      other_blog = FactoryBot.create(:blog, user: other_user)

      expect(user.following_blogs).to include(user_blog, following_blog)
      expect(user.following_blogs).not_to include(other_blog)
    end
  end

  describe '#following?' do
    context 'フォローしている時' do
      it 'trueを返す' do
        user, other = FactoryBot.create_list(:user, 2)
        user.follow!(other)

        expect(user).to be_following(other.id)
        expect(user).to be_following(other)
      end
    end

    context 'フォローしていない時' do
      it 'falseを返す' do
        user, other = FactoryBot.create_list(:user, 2)

        expect(user).not_to be_following(other.id)
        expect(user).not_to be_following(other)
      end
    end

    context '自分自身の時' do
      it 'falseを返す' do
        user = FactoryBot.create(:user)

        expect(user).not_to be_following(user.id)
        expect(user).not_to be_following(user)
      end
    end
  end

  describe '#unfollow' do
    it 'フォローしている人をフォロー解除する事ができる' do
      user_a, user_b = FactoryBot.create_list(:user, 2)
      user_a.follow!(user_b)

      expect(user_a.following).to be_include(user_b)
      expect(user_b.followers).to be_include(user_a)

      # フォロー解除
      user_a.unfollow(user_b)

      expect(user_a.following).not_to be_include(user_b)
      expect(user_b.followers).not_to be_include(user_a)
    end

    it 'フォローしていない人をフォロー解除しても例外は発生しない' do
      user_a, user_b = FactoryBot.create_list(:user, 2)
      expect(user_a.following).not_to be_include(user_b)
      expect(user_b.followers).not_to be_include(user_a)

      expect(user_a.unfollow(user_b)).to be_nil
    end
  end

  describe '#unfollow!' do
    it 'フォローしている人をフォロー解除する事ができる' do
      user_a, user_b = FactoryBot.create_list(:user, 2)
      user_a.follow!(user_b)

      expect(user_a.following).to be_include(user_b)
      expect(user_b.followers).to be_include(user_a)

      # フォロー解除
      expect(user_a.unfollow!(user_b)).to be_a(UserRelationship)

      expect(user_a.following).not_to be_include(user_b)
      expect(user_b.followers).not_to be_include(user_a)
    end

    it 'フォローしていない人をフォロー解除すると例外が発生する' do
      user_a, user_b = FactoryBot.create_list(:user, 2)
      expect(user_a.following).not_to be_include(user_b)
      expect(user_b.followers).not_to be_include(user_a)

      expect { user_a.unfollow!(user_b) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'フォロー解除に失敗すると例外が発生する' do
      original_callbacks = UserRelationship.__callbacks
      UserRelationship.before_destroy -> { throw :abort }

      user_a, user_b = FactoryBot.create_list(:user, 2)
      user_a.follow!(user_b)

      expect { user_a.unfollow!(user_b) }.to raise_error(ActiveRecord::RecordNotDestroyed)

      UserRelationship.__callbacks = original_callbacks
    end
  end

  describe '#like!' do
    it '「いいね」できる' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)

      expect { user.like!(blog) }.to change(UserFavoriteBlog, :count).by(1)

      expect(user.likes_blogs).to be_include(blog)
    end

    it '自分のBlogを「いいね」するとActiveRecord::RecordInvalidが発生する' do
      blog = FactoryBot.create(:blog)

      expect { blog.user.like!(blog) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it '既に「いいね」したBlogを「いいね」するとActiveRecord::RecordInvalidが発生する' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)

      user.like!(blog)

      expect { user.like!(blog) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#likable?' do
    it '自分のBlogには「いいね」できない' do
      blog = FactoryBot.create(:blog)
      expect(blog.user).not_to be_likable(blog)
    end

    it '既に「いいね」したBlogには「いいね」できない' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)
      user.like!(blog)

      expect(user).not_to be_likable(blog)
    end

    it '人のBlogで「いいね」してなければ「いいね」できる' do
      user = FactoryBot.create(:user)
      blog = FactoryBot.create(:blog)
      expect(user.likes_blogs).not_to be_include(blog)

      expect(user).to be_likable(blog)
    end
  end
end
