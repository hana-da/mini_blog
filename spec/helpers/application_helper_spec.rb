# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#invalid_feedback_tag' do
    before do
      stub_const('DummyModel', Class.new do
        include ActiveModel::Validations

        attr_accessor :name

        validates :name, presence:  true,
                         length:    { maximum: 5 },
                         exclusion: { in: ['NG WORD'] }
      end)
    end

    context 'modelにerrorが登録されていない時' do
      it '中身のないdiv.invalid-feedbackタグが返る' do
        model = DummyModel.new.tap { |m| m.name = 'decoy' }
        model.validate
        expect(model.errors).to be_empty

        expect(helper.invalid_feedback_tag(model, :name))
          .to be_instance_of(ActiveSupport::SafeBuffer)
          .and have_css('div.invalid-feedback',
                        text: '')
      end
    end

    context 'modelにerrorが登録されている時' do
      it 'エラーメッセージを中身としたdiv.invalid-feedbackタグが返る' do
        model = DummyModel.new.tap { |m| m.name = 'NG WORD' }
        model.validate
        expect(model.errors.count).to eq(2)

        expect(helper.invalid_feedback_tag(model, :name))
          .to be_instance_of(ActiveSupport::SafeBuffer)
          .and have_css('div.invalid-feedback',
                        text: model.errors.full_messages_for(:name).join(I18n.t('support.array.words_connector')))
      end
    end
  end

  describe '#nav_link_to' do
    context 'current_page? が 真 の時' do
      before do
        allow(helper).to receive(:current_page?).and_return(true)
      end

      it 'a.nav-link.active タグが返る' do
        expect(helper.nav_link_to('name', 'url'))
          .to have_css('a.nav-link.active[href="url"]',
                       text: 'name')
      end
    end

    context 'current_page? が 偽 の時' do
      before do
        allow(helper).to receive(:current_page?).and_return(false)
      end

      it 'a.nav-link の タグが返る' do
        expect(helper.nav_link_to('name', 'url'))
          .to have_css('a.nav-link[href="url"]',
                       text: 'name')
      end
    end
  end

  describe '#users_to_link_tag' do
    it 'suffixに空文字列を渡しても例外は発生しない' do
      expect { helper.users_to_link_tag([], '') }.not_to raise_error
    end

    context 'suffixなしの時で' do
      context 'users が空の時' do
        it do
          expect(helper.users_to_link_tag([]))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_text(' ')
        end
      end

      context 'users の要素が1つの時' do
        it do
          user = FactoryBot.create(:user)

          expect(helper.users_to_link_tag([user]))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(user.username, href: user_path(user))
            .and have_text("#{user.username} ")
        end
      end

      context 'users の要素が2つの時' do
        it do
          users = FactoryBot.create_list(:user, 2)

          expect(helper.users_to_link_tag(users))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(users.first.username, href: user_path(users.first))
            .and have_link(users.second.username, href: user_path(users.second))
            .and have_text("#{users.map(&:username).join(I18n.t('support.array.words_connector'))} ")
        end
      end
    end

    context 'suffixがロケールキーでない時' do
      context 'users が空の時' do
        it do
          suffix = :never_exists_like_this_key

          expect(helper.users_to_link_tag([], suffix))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_text(' ' + suffix.to_s)
        end
      end

      context 'users の要素が1つの時' do
        it do
          suffix = :never_exists_like_this_key
          user = FactoryBot.create(:user)

          expect(helper.users_to_link_tag([user], suffix))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(user.username, href: user_path(user))
            .and have_text("#{user.username} " + suffix.to_s)
        end
      end

      context 'users の要素が2つの時' do
        it do
          suffix = :never_exists_like_this_key
          users = FactoryBot.create_list(:user, 2)

          expect(helper.users_to_link_tag(users, suffix))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(users.first.username, href: user_path(users.first))
            .and have_link(users.second.username, href: user_path(users.second))
            .and have_text("#{users.map(&:username).join(I18n.t('support.array.words_connector'))} " + suffix.to_s)
        end
      end
    end

    context 'suffixがロケールキーの時' do
      context 'users が空の時' do
        it do
          locale_key = :liked_users

          expect(helper.users_to_link_tag([], locale_key))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_text(' ' +
                            I18n.t("helpers.users_to_link_tag.suffix.#{locale_key}", count: 0))
        end
      end

      context 'users の要素が1つの時' do
        it do
          locale_key = :liked_users
          user = FactoryBot.create(:user)

          expect(helper.users_to_link_tag([user], locale_key))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(user.username, href: user_path(user))
            .and have_text("#{user.username} " +
                            I18n.t("helpers.users_to_link_tag.suffix.#{locale_key}", count: 1))
        end
      end

      context 'users の要素が2つの時' do
        it do
          locale_key = :liked_users
          users = FactoryBot.create_list(:user, 2)

          expect(helper.users_to_link_tag(users, locale_key))
            .to be_instance_of(ActiveSupport::SafeBuffer)
            .and have_link(users.first.username, href: user_path(users.first))
            .and have_link(users.second.username, href: user_path(users.second))
            .and have_text("#{users.map(&:username).join(I18n.t('support.array.words_connector'))} " +
                            I18n.t("helpers.users_to_link_tag.suffix.#{locale_key}", count: 2))
        end
      end
    end
  end
end
