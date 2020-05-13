# frozen_string_literal: true

module ApplicationHelper
  # modelのattributeに対するエラーメッセージの div.invalid-feedback タグを返す
  #
  # @param [ApplicationRecord] model
  # @param [Symbol] attribute
  # @return [ActiveSupport::SafeBuffer]
  def invalid_feedback_tag(model, attribute)
    tag.div(
      model.errors.full_messages_for(attribute).join(I18n.t('support.array.words_connector')),
      class: 'invalid-feedback'
    ) + "\n"
  end
end
