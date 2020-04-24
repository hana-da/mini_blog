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

    it '投稿用のフォームが表示されている' do
      visit root_path

      within('#new_blog') do
        expect(page).to have_field('blog[content]')
      end
    end
  end
end
