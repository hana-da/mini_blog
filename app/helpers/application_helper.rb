# frozen_string_literal: true

module ApplicationHelper
  # modelのattributeに対するエラーメッセージの div.invalid-feedback タグを返す
  #
  # @param [ApplicationRecord] model
  # @param [Symbol] attribute
  # @return [ActiveSupport::SafeBuffer]
  def invalid_feedback_tag(model, attribute)
    return unless model

    tag.div(
      model.errors.full_messages_for(attribute).join(I18n.t('support.array.words_connector')),
      class: 'invalid-feedback'
    ) + "\n"
  end

  # bootstarap の .nav-link を付与した a タグを返す
  #
  # リンク先が現在のページの場合には .active も付与する
  #
  # @param [String] name link_toの第1引数
  # @param [String, Hash] options link_toの第2引数
  # @return [ActiveSupport::SafeBuffer]
  def nav_link_to(name, options)
    link_to(name, options, class: "nav-link #{current_page?(url_for(options)) && 'active'}")
  end

  # usersをそれぞれのuser_pathのリンクにした文字列を返す
  #
  # @param [Array<User>] users Userのコレクション
  # @param [String, Symbol] suffix 最後につける文字列、またはI18nのlocale key
  # @return [ActiveSupport::SafeBuffer]
  def users_to_link_tag(users, suffix = nil)
    user_links = users.map { |u| link_to(u.username, user_path(u)) }

    locale_key = "helpers.users_to_link_tag.suffix.#{suffix}"
    suffix = I18n.exists?(locale_key) ? I18n.t(locale_key, count: users.size) : suffix if suffix.present?

    safe_join(user_links, I18n.t('support.array.words_connector')) + tag.small(" #{suffix}")
  end
end
