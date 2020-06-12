# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/', type: :system do
  it '全ての投稿が降順に表示される' do
    blogs = 3.times.map do |i|
      travel_to((5 - i).day.ago) { FactoryBot.create(:blog) }
    end

    visit root_path

    expect(page).to have_css('li.blogs__blog', count: blogs.count)

    blogs.each do |blog|
      within("li#blog-#{blog.id}") do
        expect(page).to have_link(blog.user.username, href: user_path(blog.user))
        expect(page).to have_css('article.blogs__blog-content', text: blog.content)
        expect(page).to have_css('.blogs__blog-timestamp', text: l(blog.created_at, format: :long))
      end
    end

    # 表示順の確認
    oldest_blog, latest_blog = blogs.minmax_by(&:created_at)
    expect(page).to have_css('ol#blogs > li:first-child .blogs__blog-timestamp',
                             text: l(latest_blog.created_at, format: :long))
    expect(page).to have_css('ol#blogs > li:last-child  .blogs__blog-timestamp',
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

    describe 'コメント欄' do
      it 'コメント用のフォームは表示されていない' do
        FactoryBot.create(:blog)
        visit root_path

        expect(page).not_to have_css('.blogs__blog-comment-form')
      end

      it 'コメントは表示されている' do
        comment = FactoryBot.create(:blog_comment)
        visit root_path

        within("#blogs--blog-comment-#{comment.id}") do
          expect(page).to have_css('.blogs--blog-comment-content', text: comment.content)
            .and have_link(comment.user.username, href: user_path(comment.user))
            .and have_css('.blogs--blog-comment-timestamp', text: l(comment.created_at, format: :long))
        end
      end
    end

    it 'フォローする/フォロー解除ボタンは表示されていない' do
      FactoryBot.create(:blog)

      visit root_path

      expect(page).not_to have_button(t('helpers.submit.follow'))
      expect(page).not_to have_button(t('helpers.submit.unfollow'))
    end

    it '「いいね」ボタンは押せないが、「いいね」の数を表示するために見えている' do
      blog = FactoryBot.create(:blog)
      favorite = FactoryBot.create(:user_favorite_blog)
      favorited_blog = favorite.blog

      visit root_path
      within("li#blog-#{favorited_blog.id}") do
        expect(page).to have_css("#like-button-#{favorited_blog.id}[disabled='disabled']",
                                 text: "1 #{t('helpers.submit.like')}")
      end

      within("li#blog-#{blog.id}") do
        expect(page).to have_css("#like-button-#{blog.id}[disabled='disabled']",
                                 text: "0 #{t('helpers.submit.like')}")
      end
    end

    it '「いいね」したユーザのusernameがリンクで表示されている' do
      no_favorited_blog = FactoryBot.create(:blog)
      favorited_blog = FactoryBot.create(:blog)
      favorited_users = FactoryBot.create_list(:user_favorite_blog, 3, blog: favorited_blog).map(&:user)

      visit root_path
      within("li#blog-#{favorited_blog.id} .blogs__blog-favorited-users") do
        favorited_users.each do |user|
          expect(page).to have_link(user.username, href: user_path(user))
        end
      end
      within("li#blog-#{no_favorited_blog.id} .blogs__blog-favorited-users") do
        expect(page).not_to have_link
      end
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

        expect(page).to have_link(user.username, href: timeline_current_user_path)
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
      expect(page).to have_css('article.blogs__blog-content', text: content)
      expect(page.find('textarea#blog_content').value).to be_blank
      expect(page).not_to have_css('img.blogs__blog-image')
    end

    it '投稿用のフォームから画像付きでも投稿できる' do
      visit root_path

      content = FactoryBot.build(:blog).content

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: content
        attach_file 'spec/fixtures/images/bike.jpg', name: 'blog[image]'

        click_button
      end

      expect(page).to have_current_path(root_path)
      expect(page).to have_css('article.blogs__blog-content', text: content)
      expect(page.find('textarea#blog_content').value).to be_blank
      expect(page).to have_css('img.blogs__blog-image')
    end

    it '画像でないファイルを投稿するとエラーメッセージが表示される', js: true do
      visit root_path

      blog = FactoryBot.build(:blog)
      errors = blog.errors

      within('#new_blog') do
        expect(page).not_to have_css('.field_with_errors > textarea#blog_content')

        fill_in 'blog[content]', with: blog.content
        attach_file 'README.md', name: 'blog[image]'

        expect { click_button }.not_to change(Blog, :count)
      end

      within('#new_blog') do
        expect(page).to have_css('.field_with_errors > input#blog_image')
        expect(page).to have_css('.field_with_errors + .invalid-feedback',
                                 text: errors.full_message(:image,
                                                           errors.generate_message(:image,
                                                                                   :content_type_whitelist_error)))
      end
    end

    it '長文を投稿しようとするとエラーメッセージが表示される', js: true do
      visit root_path

      blog = FactoryBot.build(:blog, content: 'a' * 1000).tap(&:validate)

      within('#new_blog') do
        fill_in 'blog[content]', with: blog.content
        click_button
      end

      within('#new_blog') do
        expect(page).to have_css('.field_with_errors > textarea#blog_content')
        expect(page).to have_css('.field_with_errors + .invalid-feedback',
                                 text: blog.errors.full_messages_for(:content).first)
      end
    end

    describe 'コメント欄で', js: true do
      it 'コメント用のフォームでコメントを投稿することができる' do
        blog = FactoryBot.create(:blog)
        comment = FactoryBot.build(:blog_comment)

        visit root_path

        within("#blog-#{blog.id}") do
          expect(page).not_to have_css('.blogs--blog-comment')

          fill_in 'blog_comment[content]', with: comment.content
          click_button(t('helpers.submit.comment'))
        end

        within("#blog-#{blog.id}") do
          expect(page).to have_css('.blogs--blog-comment', count: 1)

          expect(page).to have_css('.blogs--blog-comment-content', text: comment.content)
            .and have_link(user.username, href: user_path(user))
            .and have_css('.blogs--blog-comment-timestamp')

          expect(page).to have_no_css('.field_with_errors + .invalid-feedback')
            .and have_no_css('input[type="hidden"][name="_method"][value="delete"]', visible: :hidden)
            .and have_no_css('input[type="text"][value]')
        end
      end

      context 'コメントの追加に成功した時' do
        it 'コメントしたBlogの投稿者がemailを登録していれば通知メールが送信される' do
          blog = FactoryBot.create(:blog)
          expect(blog.user.email).to be_present

          visit root_path

          within("#blog-#{blog.id}") do
            expect(page).not_to have_css('.blogs--blog-comment')
            fill_in 'blog_comment[content]', with: FactoryBot.attributes_for(:blog_comment)[:content]

            click_button(t('helpers.submit.comment'))
          end

          within("#blog-#{blog.id}") do
            expect(page).to have_css('.blogs--blog-comment', count: 1)

            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(ActionMailer::Base.deliveries.last.to).to eq([blog.user.email])
          end
        end

        it 'コメントしたBlogの投稿者がemailを登録していないと通知メールは送信されない' do
          non_email_user = FactoryBot.build(:user, email: '').tap { |user| user.save!(validate: false) }
          blog = FactoryBot.create(:blog, user: non_email_user)
          expect(blog.user.email).to be_blank

          visit root_path

          within("#blog-#{blog.id}") do
            expect(page).not_to have_css('.blogs--blog-comment')

            fill_in 'blog_comment[content]', with: FactoryBot.attributes_for(:blog_comment)[:content]

            click_button(t('helpers.submit.comment'))
          end

          within("#blog-#{blog.id}") do
            expect(page).to have_css('.blogs--blog-comment', count: 1)

            expect(ActionMailer::Base.deliveries.count).to be_zero
          end
        end

        context '追加しようとしたコメントがinvalidの時' do
          it 'コメントのerrorsメッセージが表示される' do
            blog = FactoryBot.create(:blog)
            comment = FactoryBot.build(:blog_comment, blog: blog, content: 'a' * 1000)
            expect(comment).to be_invalid

            visit root_path

            within("#blog-#{blog.id}") do
              expect(page).not_to have_css('.blogs--blog-comment')

              fill_in 'blog_comment[content]', with: comment.content

              click_button(t('helpers.submit.comment'))
            end

            within("#blog-#{blog.id}") do
              expect(page).to have_css('.field_with_errors > input#blog_comment_content')
              expect(page).to have_css('.field_with_errors + .invalid-feedback',
                                       text: comment.errors.full_messages_for(:content).first)
            end
          end
        end
      end

      context 'コメントの追加に失敗した時', js: true do
        it '通知メールは送信されない' do
          blog = FactoryBot.create(:blog)
          expect(blog.user.email).to be_present

          visit root_path

          within("#blog-#{blog.id}") do
            expect(page).not_to have_css('.blogs--blog-comment')

            click_button(t('helpers.submit.comment'))
          end

          within("#blog-#{blog.id}") do
            expect(page).to have_css('.blogs--blog-comment', count: 0)

            expect(ActionMailer::Base.deliveries.count).to be_zero
          end
        end
      end
    end

    describe '「いいね」ボタン' do
      it '自分の投稿でも「いいね」の数を表示するために「いいね」ボタンは表示されている。が、押せない' do
        blog = FactoryBot.create(:blog, user: user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_css("#like-button-#{blog.id}[disabled='disabled']",
                                   text: "0 #{t('helpers.submit.like')}")
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

      it '「いいね」ボタンで投稿に「いいね」する事ができる', js: true do
        blog = FactoryBot.create(:blog)
        expect(blog.liked_users).not_to include(user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button("like-button-#{blog.id}")
        end

        within("li#blog-#{blog.id}") do
          expect(page).to have_link(user.username)
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

    it '「いいね」したユーザのusernameがリンクで表示されている' do
      blog = FactoryBot.create(:blog)
      favorited_blog = FactoryBot.create(:blog)
      favorited_users = FactoryBot.create_list(:user_favorite_blog, 3, blog: favorited_blog).map(&:user)

      visit root_path
      within("li#blog-#{favorited_blog.id} .blogs__blog-favorited-users") do
        favorited_users.each do |user|
          expect(page).to have_link(user.username, href: user_path(user))
        end
      end
      within("li#blog-#{blog.id} .blogs__blog-favorited-users") do
        expect(page).not_to have_link
      end
    end

    it '自分の投稿にはフォローボタンは表示されていない' do
      blog = FactoryBot.create(:blog, user: user)

      visit root_path
      within("li#blog-#{blog.id}") do
        expect(page).not_to have_button(t('helpers.submit.follow'))
        expect(page).not_to have_button(t('helpers.submit.unfollow'))
      end
    end

    describe 'フォロー/フォロー解除の動作' do
      it 'フォローしていないユーザの投稿には「フォローする」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        expect(user).not_to be_following(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_button(t('helpers.submit.follow'))
        end
      end

      it '「フォローする」ボタンでユーザをフォローできる', js: true do
        author = FactoryBot.create(:user)
        blogs = FactoryBot.create_list(:blog, 3, user: author)
        blog  = blogs.first
        _other_authors_blog = FactoryBot.create(:blog)

        expect(user).not_to be_following(blog.user)

        visit root_path

        expect(page).to have_button(t('helpers.submit.follow'), count: Blog.count)
        expect(page).not_to have_button(t('helpers.submit.unfollow'))

        within("li#blog-#{blog.id}") do
          click_button(t('helpers.submit.follow'))
        end

        # 「フォローする」ボタンが「フォロー解除」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_button(t('helpers.submit.follow'))
          expect(page).to have_button(t('helpers.submit.unfollow'))
        end

        # 同一userの「フォローする」ボタンは全て「フォロー解除」ボタンになっている
        expect(page).to have_button(t('helpers.submit.unfollow'), count: blogs.count)
        # 違うuserの「フォローする」ボタンは残っている
        expect(page).to have_button(t('helpers.submit.follow'), count: 1)

        expect(user.reload).to be_following(blog.user)
      end

      it 'フォローしているユーザの投稿には「フォロー解除」ボタンが表示されている' do
        blog = FactoryBot.create(:blog)
        user.follow!(blog.user)
        expect(user).to be_following(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          expect(page).to have_button(t('helpers.submit.unfollow'))
        end
      end

      it '「フォロー解除」ボタンでフォローを解除できる', js: true do
        author = FactoryBot.create(:user)
        blogs = FactoryBot.create_list(:blog, 3, user: author)
        blog  = blogs.first
        other_authors_blog = FactoryBot.create(:blog)

        user.follow!(blog.user)
        user.follow!(other_authors_blog.user)
        expect(user).to be_following(blog.user)

        visit root_path
        within("li#blog-#{blog.id}") do
          click_button(t('helpers.submit.unfollow'))
        end

        # 「フォロー解除」ボタンが「フォローする」ボタンになる
        within("li#blog-#{blog.id}") do
          expect(page).not_to have_button(t('helpers.submit.unfollow'))
          expect(page).to have_button(t('helpers.submit.follow'))
        end

        # 同一userの「フォロー解除」ボタンは全て「フォローする」ボタンになっている
        expect(page).to have_button(t('helpers.submit.follow'), count: blogs.count)
        # 違うuserの「フォロー解除」ボタンは残っている
        expect(page).to have_button(t('helpers.submit.unfollow'), count: 1)

        expect(user.reload).not_to be_following(blog.user)
      end
    end
  end
end
