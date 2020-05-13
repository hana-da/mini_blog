# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  before do
    stub_const('DummyModel', Class.new do
      include ActiveModel::Validations

      attr_accessor :name

      validates :name, presence:  true,
                       length:    { maximum: 5 },
                       exclusion: { in: ['NG WORD'] }
    end)
  end

  describe '#invalid_feedback_tag' do
    context 'modelにerrorが登録されていない時' do
      it '中身のないdiv.invalid-feedbackタグが返る' do
        model = DummyModel.new.tap { |m| m.name = 'decoy' }
        model.validate
        expect(model.errors).to be_empty

        expect(helper.invalid_feedback_tag(model, :name)).to be_instance_of(ActiveSupport::SafeBuffer)
          .and eq(<<~HTML)
            <div class="invalid-feedback"></div>
          HTML
      end
    end

    context 'modelにerrorが登録されている時' do
      it 'エラーメッセージを中身としたdiv.invalid-feedbackタグが返る' do
        model = DummyModel.new.tap { |m| m.name = 'NG WORD' }
        model.validate
        expect(model.errors.count).to eq(2)

        expect(helper.invalid_feedback_tag(model, :name)).to be_instance_of(ActiveSupport::SafeBuffer)
          .and eq(<<~HTML)
            <div class="invalid-feedback">#{model.errors.full_messages_for(:name).join(I18n.t('support.array.words_connector'))}</div>
          HTML
      end
    end
  end
end
