# frozen_string_literal: true

class AddUserIdToBlog < ActiveRecord::Migration[6.0]
  def up
    create_unknown_user_id_0 if any_blogs? && unknown_user_not_exist?

    add_reference :blogs, :user, foreign_key: true, null: false, default: 0
  end

  def down
    remove_reference :blogs, :user
  end

  private def any_blogs?
    ApplicationRecord.connection.select_value('SELECT count(*) FROM blogs').positive?
  end

  private def unknown_user_not_exist?
    ApplicationRecord.connection.select_value('SELECT count(*) FROM users WHERE id = 0').zero?
  end

  private def create_unknown_user_id_0
    ApplicationRecord.connection.execute(
      ApplicationRecord.sanitize_sql_array(
        [
          "INSERT INTO users(id, username, created_at, updated_at) VALUES(0, 'Unknown', :current, :current)",
          { current: Time.zone.now },
        ]
      )
    )
  end
end
