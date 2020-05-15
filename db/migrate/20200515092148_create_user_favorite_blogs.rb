# frozen_string_literal: true

class CreateUserFavoriteBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :user_favorite_blogs do |t|
      t.references :blog, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false

      t.timestamps
    end

    add_index :user_favorite_blogs, %i[blog_id user_id], unique: true
  end
end
