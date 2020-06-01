# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/users/timeline', type: :feature do
  context 'ログインしていない時' do
    it 'ログインを求められる' do
      visit user_timeline_path

      expect(page).to have_current_path(new_user_session_path)
    end
  end

  context 'ログインしている時' do
    let!(:user) { FactoryBot.create(:user) }

    before do
      sign_in(user)
    end

    it '自分とフォローしているユーザの投稿のみが降順に表示される' do
      following_user = FactoryBot.create(:user).tap { |u| user.follow!(u) }
      other_user = FactoryBot.create(:user)

      expect(user).to be_following(following_user)
      expect(user).not_to be_following(other_user)

      user_blog, following_blog, other_blog = [user, following_user, other_user].map.with_index do |author, i|
        travel_to((5 - i).day.ago) { FactoryBot.create(:blog, user: author) }
      end

      visit user_timeline_path

      expect(page).to have_css("li#blog-#{user_blog.id}")
      expect(page).to have_css("li#blog-#{following_blog.id}")
      expect(page).not_to have_css("li#blog-#{other_blog.id}")

      # 表示順の確認
      oldest_blog, latest_blog = [user_blog, following_blog].minmax_by(&:created_at)
      expect(page).to have_css('ol#blogs > li:first-child .blogs__blog-timestamp',
                               text: l(latest_blog.created_at, format: :long))
      expect(page).to have_css('ol#blogs > li:last-child  .blogs__blog-timestamp',
                               text: l(oldest_blog.created_at, format: :long))
    end

    it '投稿用のフォームからフォームを投稿できる' do
      visit user_timeline_path

      content = FactoryBot.attributes_for(:blog)[:content]

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: content
        click_button
      end

      expect(page).to have_current_path(user_timeline_path)
      expect(page).to have_css('article.blogs__blog-content', text: content)
      expect(page.find('textarea#blog_content').value).to be_blank
    end

    it '投稿用のフォームから画像付きでも投稿できる' do
      visit user_timeline_path

      content = FactoryBot.build(:blog).content

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: content
        attach_file 'spec/fixtures/images/bike.jpg', name: 'blog[image]'

        click_button
      end

      expect(page).to have_current_path(user_timeline_path)
      expect(page).to have_css('article.blogs__blog-content', text: content)
      expect(page.find('textarea#blog_content').value).to be_blank
      expect(page).to have_css('img.blogs__blog-image')
    end

    it '画像でないファイルを投稿するとエラーメッセージが表示される' do
      visit user_timeline_path

      blog = FactoryBot.build(:blog)
      errors = blog.errors

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: blog.content
        attach_file 'README.md', name: 'blog[image]'

        expect { click_button }.not_to change(Blog, :count)
      end

      page.driver.response.body = unescape(page.body).lines
      within('#new_blog') do
        expect(page).to have_css('.field_with_errors > input#blog_image')
        expect(page).to have_css('.field_with_errors + .invalid-feedback',
                                 text: errors.full_message(:image,
                                                           errors.generate_message(:image,
                                                                                   :content_type_whitelist_error)))
      end
    end

    it '長文を投稿しようとするとエラーメッセージが表示される' do
      visit user_timeline_path

      blog = FactoryBot.build(:blog, content: 'a' * 1000).tap(&:validate)

      within('#new_blog') do
        fill_in 'blog[content]', with: blog.content
        click_button
      end

      page.driver.response.body = unescape(page.body).lines
      within('#new_blog') do
        expect(page).to have_css('.field_with_errors > textarea#blog_content')
        expect(page).to have_css('.field_with_errors + .invalid-feedback',
                                 text: blog.errors.full_messages_for(:content).first)
      end
    end
  end
end
