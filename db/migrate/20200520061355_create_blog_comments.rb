# frozen_string_literal: true

class CreateBlogComments < ActiveRecord::Migration[6.0]
  def change
    create_table :blog_comments do |t|
      t.text :content, null: false
      t.references :blog, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
