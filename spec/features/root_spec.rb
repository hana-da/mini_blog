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
    it '投稿用のフォームは表示されていない' do
      visit root_path

      expect(page).not_to have_css('#new_blog')
    end
  end

  context 'ログインしている時' do
    before do
      sign_in FactoryBot.create(:user)
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
  end

  describe 'navbarには' do
    context 'ログインしていない時' do
      it 'ログイン用とサインアップ用のリンクが表示されている' do
        visit root_path

        expect(page).to have_link(t('devise.shared.links.sign_in'), href: user_session_path)
        expect(page).to have_link(t('devise.shared.links.sign_up'), href: new_user_registration_path)
      end
    end

    context 'ログインしている時' do
      let!(:user) { FactoryBot.create(:user) }

      before do
        sign_in(user)
      end

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
  end
end
