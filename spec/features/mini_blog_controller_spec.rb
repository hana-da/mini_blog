# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MiniBlogControllers', type: :feature do
  context 'rootページでは' do
    let!(:blogs) { FactoryBot.create_list(:blog, 3) }

    it '全ての投稿が表示される' do
      visit root_path

      expect(page).to have_css('li.blogs__blog', count: blogs.count)

      blogs.each do |blog|
        within("li#blog-#{blog.id}") do
          expect(page).to have_css('span.blogs__blog-content', text: blog.content)
          expect(page).to have_css('span.blogs__blog-timestamp', text: l(blog.created_at, format: :long))
        end
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
  end

  describe 'navbarには' do
    context 'ログインしていない時' do
      it 'サインアップ用のリンクが表示されている' do
        visit root_path

        expect(page).to have_link(t('devise.shared.links.sign_up'), href: new_user_registration_path)
      end
    end
  end
end
