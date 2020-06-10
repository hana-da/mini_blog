# frozen_string_literal: true

module MiniBlogHelper
  # current_user が user_id の User をフォローしていない時はフォロー用のタグを
  # フォローしている時はフォロー解除用のタグを返す
  #
  # @param [User, Integer] user_id フォロー/フォロー解除するUserかUser#id
  # @return [ActiveSupport::SafeBuffer, nil]
  def follow_unfollow_button_tag(user_or_id)
    return unless current_user

    user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id
    return if current_user.id == user_id

    if current_user.following?(user_id)
      unfollow_button_tag(user_id)
    else
      follow_button_tag(user_id)
    end
  end

  # フォローするためのフォームタグ
  #
  # @param [Integer] user_id フォローするUserのid
  # @return [ActiveSupport::SafeBuffer]
  def follow_button_tag(user_id)
    button_to(t('helpers.submit.follow'),
              current_user_relationship_path,
              method: :post,
              params: { followed_id: user_id },
              remote: true,
              class:  'btn btn-primary btn-sm')
  end

  # フォロー解除するためのフォームタグ
  #
  # @param [Integer] user_id フォローを解除するUserのid
  # @return [ActiveSupport::SafeBuffer]
  def unfollow_button_tag(user_id)
    button_to(t('helpers.submit.unfollow'),
              current_user_relationship_path,
              method: :delete,
              params: { followed_id: user_id },
              class:  'btn btn-outline-primary btn-sm')
  end

  # 「いいね」ボタンのタグ
  #
  # current_user.likable?(blog) が偽の場合は button に disabled="disabled" が付与される
  #
  # @param [Blog] blog いいねする対象のBlog
  # @param [Integer] count 現在のいいねの数
  # @return [ActiveSupport::SafeBuffer]
  def favorite_button_tag(blog:, count:)
    button_to(blog_like_path(blog.id),
              id:       "like-button-#{blog.id}",
              class:    'btn btn-primary btn-sm',
              remote:   true,
              disabled: !current_user&.likable?(blog)) do
      tag.span(count, class: 'badge badge-pill badge-light') +
        ' ' +
        tag.span(t('helpers.submit.like'))
    end
  end
end
