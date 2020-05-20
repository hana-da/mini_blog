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
          helper.current_user.follow(user)
          expect(helper.current_user).to be_following(user)

          actual = helper.follow_unfollow_button_tag(user.id)
          expect(actual).to be_instance_of(ActiveSupport::SafeBuffer)

          expect(Nokogiri::HTML.fragment(actual)).to have_css("form[action='#{unfollow_user_path}'][method='post']")
            .and have_css("input[type='hidden'][name='id'][value='#{user.id}']", visible: :hidden)
            .and have_css("input[type='submit'][value='#{t('helpers.submit.unfollow')}']")
        end
      end

      context 'current_userがuser_idをフォローしていない時' do
        it '「フォローする」のボタンのtagが返る' do
          user = FactoryBot.create(:user)
          expect(helper.current_user).not_to be_following(user)

          actual = helper.follow_unfollow_button_tag(user.id)
          expect(actual).to be_instance_of(ActiveSupport::SafeBuffer)

          expect(Nokogiri::HTML.fragment(actual)).to have_css("form[action='#{follow_user_path}'][method='post']")
            .and have_css("input[type='hidden'][name='id'][value='#{user.id}']", visible: :hidden)
            .and have_css("input[type='submit'][value='#{t('helpers.submit.follow')}']")
        end
      end
    end

    context 'ログインしていない時' do
      before do
        allow(helper).to receive(:current_user).and_return(nil)
      end

      it do
        expect(helper.follow_unfollow_button_tag(1)).to be_nil
      end
    end
  end
end
