# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/', type: :feature do
  it '全ての投稿が表示される' do
    blogs = FactoryBot.create_list(:blog, 3)

    visit root_path

    expect(page).to have_css('li.blogs__blog', count: blogs.count)

    blogs.each do |blog|
      within("li#blog-#{blog.id}") do
        expect(page).to have_link(blog.user.username, href: user_path(blog.user))
        expect(page).to have_css('span.blogs__blog-content', text: blog.content)
        expect(page).to have_css('span.blogs__blog-timestamp', text: l(blog.created_at, format: :long))
      end
    end
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

      expect(page).not_to have_button(t('.follow'))
      expect(page).not_to have_button(t('.unfollow'))
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    describe 'navbarには' do
      it 'ユーザー名とログアウト用のリンクが表示されている' do
        visit root_path

        expect(page).to have_link(user.username, href: user_path(user))
        expect(page).to have_css(%(a[data-method="delete"][href="#{destroy_user_session_path}"]),
                                 text: t('devise.shared.links.sign_out'))
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
        fill_in 'blog[content]', with: content
        click_button
      end

      expect(page).to have_current_path(root_path, ignore_query: true)
      expect(page).to have_css('span.blogs__blog-content', text: content)
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

    it '自分の投稿にはフォローボタンは表示されていない' do
      blog = FactoryBot.create(:blog, user: user)

      visit root_path
      within("li#blog-#{blog.id}") do
        expect(page).not_to have_css(%(form[action="#{follow_user_path}"]))
        expect(page).not_to have_button(t('.follow'))

        expect(page).not_to have_css(%(form[action="#{unfollow_user_path}"]))
        expect(page).not_to have_button(t('.unfollow'))
      end
    end

    describe 'フォロー/フォロー解除の動作' do
      it 'フォローしていないユーザの投稿には「フォローする」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        expect(user.following).not_to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).to have_button(t('.follow'))
        end
      end

      it '「フォローする」ボタンでユーザをフォローできる' do
        blog = FactoryBot.create(:blog)
        expect(user.following).not_to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button(t('.follow'))
        end

        expect(user.following.reload).to include(blog.user)

        # 「フォローする」ボタンが「フォロー解除」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).not_to have_button(t('.follow'))

          expect(page).to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).to have_button(t('.unfollow'))
        end
      end

      it 'フォローしているユーザの投稿には「フォロー解除」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        user.follow(blog.user)
        expect(user.following).to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).to have_button(t('.unfollow'))
        end
      end

      it '「フォロー解除」ボタンでフォローを解除できる' do
        blog = FactoryBot.create(:blog)
        user.follow(blog.user)
        expect(user.following).to include(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button(t('.unfollow'))
        end

        expect(user.following.reload).not_to include(blog.user)

        # 「フォロー解除」ボタンが「フォローする」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_css(%(form[action="#{unfollow_user_path}"]))
          expect(page).not_to have_button(t('.unfollow'))

          expect(page).to have_css(%(form[action="#{follow_user_path}"]))
          expect(page).to have_button(t('.follow'))
        end
      end
    end
  end
end
