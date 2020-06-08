# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiniBlogHelper, type: :helper do
  describe '#follow_unfollow_button_tag' do
    context 'ログインしている時' do
      before do
        allow(helper).to receive(:current_user).and_return(FactoryBot.create(:user))
      end

      context 'current_userがuser_idをフォローしている時' do
        it '「フォロー解除」のボタンのtagが返る' do
          user = FactoryBot.create(:user)
          helper.current_user.follow!(user)
          expect(helper.current_user).to be_following(user)

          expect(helper.follow_unfollow_button_tag(user.id))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_css("form[action='#{current_user_relationship_path}'][method='post']")
            .and have_css("input[type='hidden'][name='_method'][value='delete']", visible: :hidden)
            .and have_css("input[type='hidden'][name='followed_id'][value='#{user.id}']", visible: :hidden)
            .and have_css("input[type='submit'][value='#{t('helpers.submit.unfollow')}']")
        end
      end

      context 'current_userがuser_idをフォローしていない時' do
        it '「フォローする」のボタンのtagが返る' do
          user = FactoryBot.create(:user)
          expect(helper.current_user).not_to be_following(user)

          expect(helper.follow_unfollow_button_tag(user.id))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_css("form[action='#{current_user_relationship_path}'][method='post']")
            .and have_css("input[type='hidden'][name='followed_id'][value='#{user.id}']", visible: :hidden)
            .and have_css("input[type='submit'][value='#{t('helpers.submit.follow')}']")
        end
      end

      context 'current_user.id と user_id が同一の時' do
        it do
          expect(helper.follow_unfollow_button_tag(helper.current_user.id)).to be_nil
        end
      end
    end

    context 'ログインしていない時' do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it do
        expect(helper.follow_unfollow_button_tag(1))
          .to be_nil
      end
    end
  end

  describe '#favorite_button_tag' do
    context 'ログインしている時' do
      let(:current_user) { FactoryBot.create(:user) }

      before do
        allow(helper).to receive(:current_user).and_return(current_user)
      end

      context 'current_userが「いいね」できるblogの時' do
        before do
          allow(current_user).to receive(:likable?).and_return(true)
        end

        it do
          blog = FactoryBot.create(:blog)
          liked_count = 2

          expect(helper.favorite_button_tag(blog: blog, count: liked_count))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_none_of_selectors("button#like-button-#{blog.id}[disabled='disabled']")
            .and have_css("form[action='#{blog_like_path(blog.id)}'][method='post']")
            .and have_css("button#like-button-#{blog.id} > span.badge", text: liked_count)
            .and have_css("button#like-button-#{blog.id} > span", text: t('helpers.submit.like'))
        end
      end

      context 'current_userが「いいね」できないblogの時' do
        before do
          allow(current_user).to receive(:likable?).and_return(false)
        end

        it do
          blog = FactoryBot.create(:blog)
          liked_count = 2

          expect(helper.favorite_button_tag(blog: blog, count: liked_count))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_css("button#like-button-#{blog.id}[disabled='disabled']")
            .and have_css("form[action='#{blog_like_path(blog.id)}'][method='post']")
            .and have_css("button#like-button-#{blog.id} > span.badge", text: liked_count)
            .and have_css("button#like-button-#{blog.id} > span", text: t('helpers.submit.like'))
        end
      end
    end

    context 'ログインしていない時' do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it do
        blog = FactoryBot.create(:blog)
        liked_count = 2

        expect(helper.favorite_button_tag(blog: blog, count: liked_count))
          .to be_instance_of(ActiveSupport::SafeBuffer)
          .and have_css("button#like-button-#{blog.id}[disabled='disabled']")
          .and have_css("form[action='#{blog_like_path(blog.id)}'][method='post']")
          .and have_css("button#like-button-#{blog.id} > span.badge", text: liked_count)
          .and have_css("button#like-button-#{blog.id} > span", text: t('helpers.submit.like'))
      end
    end
  end
end
