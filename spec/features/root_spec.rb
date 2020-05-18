# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/', type: :feature do
  it '全ての投稿が降順に表示される' do
    blogs = 3.times.map do |i|
      travel_to((5 - i).day.ago) { FactoryBot.create(:blog) }
    end

    visit root_path

    expect(page).to have_css('li.blogs__blog', count: blogs.count)

    blogs.each do |blog|
      within("li#blog-#{blog.id}") do
        expect(page).to have_link(blog.user.username, href: user_path(blog.user))
        expect(page).to have_css('span.blogs__blog-content', text: blog.content)
        expect(page).to have_css('span.blogs__blog-timestamp', text: l(blog.created_at, format: :long))
      end
    end

    # 表示順の確認
    oldest_blog, latest_blog = blogs.minmax_by(&:created_at)
    expect(page).to have_css('ol#blogs > li:first-child span.blogs__blog-timestamp',
                             text: l(latest_blog.created_at, format: :long))
    expect(page).to have_css('ol#blogs > li:last-child  span.blogs__blog-timestamp',
                             text: l(oldest_blog.created_at, format: :long))
  end

  context 'ログインしていない時' do
    describe 'navbarには' do
      it 'ログイン用とサインアップ用のリンクが表示されている' do
        visit root_path

        expect(page).to have_link(t('devise.shared.links.sign_in'), href: user_session_path)
        expect(page).to have_link(t('devise.shared.links.sign_up'), href: new_user_registration_path)
      end
    end

    it '投稿用のフォームは表示されていない' do
      visit root_path

      expect(page).not_to have_css('#new_blog')
    end

    it 'フォローする/フォロー解除ボタンは表示されていない' do
      FactoryBot.create(:blog)

      visit root_path

      expect(page).not_to have_button(t('helpers.submit.follow'))
      expect(page).not_to have_button(t('helpers.submit.unfollow'))
    end

    it 'いいねボタンは表示されていない' do
      FactoryBot.create(:blog)

      visit root_path

      expect(page).not_to have_button(t('helpers.submit.like'))
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    describe 'navbarには' do
      it 'ログアウト用のリンクが表示されている' do
        visit root_path

        expect(page).to have_css(%(a[data-method="delete"][href="#{destroy_user_session_path}"]),
                                 text: t('devise.shared.links.sign_out'))
      end

      it 'ユーザのタイムラインへのリンクになったユーザ名が表示されている' do
        visit root_path

        expect(page).to have_link(user.username, href: user_timeline_path)
      end

      it 'ログアウト用のリンクをクリックするとログアウト状態になる' do
        visit root_path
        click_link(t('devise.shared.links.sign_out'))

        expect(page).not_to have_css(%(a[data-method="delete"][href="#{destroy_user_session_path}"]),
                                     text: t('devise.shared.links.sign_out'))
      end
    end

    it '投稿用のフォームからフォームを投稿できる' do
      visit root_path

      content = FactoryBot.build(:blog).content

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: content
        click_button
      end

      expect(page).to have_current_path(root_path)
      expect(page).to have_css('span.blogs__blog-content', text: content)
      expect(page.find('textarea#blog_content').value).to be_blank
    end

    it '長文を投稿しようとするとエラーメッセージが表示される' do
      visit root_path

      blog = FactoryBot.build(:blog, content: 'a' * 1000).tap(&:validate)

      within('#new_blog') do
        fill_in 'blog[content]', with: blog.content
        click_button
      end

      within('#new_blog') do
        expect(page).to have_css('.field_with_errors > textarea#blog_content')
        expect(page).to have_css('.field_with_errors + .invalid-feedback', text: blog.errors.full_messages_for(:content).first)
      end
    end

    describe '「いいね」ボタン' do
      it '自分の投稿には「いいね」ボタンは表示されていない' do
        blog = FactoryBot.create(:blog, user: user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_css(%(form[action="#{like_blog_path(blog)}"]))
          expect(page).not_to have_button(t('helpers.submit.like'))
        end
      end

      it '「いいね」済みの投稿の「いいね」ボタンは押せない' do
        favorite = FactoryBot.create(:user_favorite_blog, user: user)
        blog = favorite.blog
        expect(blog.liked_users).to include(user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css("#like-button-#{blog.id}[disabled='disabled']")
        end
      end

      it '「いいね」ボタンで投稿に「いいね」する事ができる' do
        blog = FactoryBot.create(:blog)
        expect(blog.liked_users).not_to include(user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button("like-button-#{blog.id}")
        end

        expect(blog.liked_users.reload).to include(user)
      end

      it '「いいね」ボタンには「いいね」された数が表示されている' do
        favorite = FactoryBot.create(:user_favorite_blog, user: user)
        favorited_blog = favorite.blog
        expect(favorited_blog.liked_users).to include(user)

        blog = FactoryBot.create(:blog)

        visit root_path
        within("li#blog-#{favorited_blog.id}") do
          expect(page).to have_css("#like-button-#{favorited_blog.id}", text: "1 #{t('helpers.submit.like')}")
        end

        within("li#blog-#{blog.id}") do
          expect(page).to have_css("#like-button-#{blog.id}", text: "0 #{t('helpers.submit.like')}")
        end
      end
    end

    it '自分の投稿にはフォローボタンは表示されていない' do
      blog = FactoryBot.create(:blog, user: user)

      visit root_path
      within("li#blog-#{blog.id}") do
        expect(page).not_to have_css(%(form[action="#{follow_user_path}"]))
        expect(page).not_to have_button(t('helpers.submit.follow'))

        expect(page).not_to have_css(%(form[action="#{unfollow_user_path}"]))
        expect(page).not_to have_button(t('helpers.submit.unfollow'))
      end
    end

    describe 'フォロー/フォロー解除の動作' do
      it 'フォローしていないユーザの投稿には「フォローする」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        expect(user.following).not_to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).to have_button(t('helpers.submit.follow'))
        end
      end

      it '「フォローする」ボタンでユーザをフォローできる' do
        blog = FactoryBot.create(:blog)
        expect(user.following).not_to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button(t('helpers.submit.follow'))
        end

        expect(user.following.reload).to include(blog.user)

        # 「フォローする」ボタンが「フォロー解除」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).not_to have_button(t('helpers.submit.follow'))

          expect(page).to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).to have_button(t('helpers.submit.unfollow'))
        end
      end

      it 'フォローしているユーザの投稿には「フォロー解除」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        user.follow(blog.user)
        expect(user.following).to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).to have_button(t('helpers.submit.unfollow'))
        end
      end

      it '「フォロー解除」ボタンでフォローを解除できる' do
        blog = FactoryBot.create(:blog)
        user.follow(blog.user)
        expect(user.following).to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button(t('helpers.submit.unfollow'))
        end

        expect(user.following.reload).not_to include(blog.user)

        # 「フォロー解除」ボタンが「フォローする」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).not_to have_button(t('helpers.submit.unfollow'))

          expect(page).to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).to have_button(t('helpers.submit.follow'))
        end
      end
    end
  end
end
