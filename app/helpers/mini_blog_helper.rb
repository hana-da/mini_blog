# frozen_string_literal: true

module MiniBlogHelper
  # current_user が user_id の User をフォローしていない時はフォロー用のタグを
  # フォローしている時はフォロー解除用のタグを返す
  #
  # @param [Integer] user_id フォロー/フォロー解除するUserのid
  # @return [ActiveSupport::SafeBuffer, nil]
  def follow_unfollow_button_tag(user_id)
    return unless current_user
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
    form_with(url: current_user_relationship_path, method: :post) do |f|
      f.hidden_field(:followed_id, value: user_id, id: nil) +
        f.submit(t('helpers.submit.follow'), class: 'btn btn-primary btn-sm')
    end
  end

  # フォロー解除するためのフォームタグ
  #
  # @param [Integer] user_id フォローを解除するUserのid
  # @return [ActiveSupport::SafeBuffer]
  def unfollow_button_tag(user_id)
    form_with(url: current_user_relationship_path, method: :delete) do |f|
      f.hidden_field(:followed_id, value: user_id, id: nil) +
        f.submit(t('helpers.submit.unfollow'), class: 'btn btn-outline-primary btn-sm')
    end
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
              disabled: !current_user&.likable?(blog)) do
      tag.span(count, class: 'badge badge-pill badge-light') +
        ' ' +
        tag.span(t('helpers.submit.like'))
    end
  end
end
