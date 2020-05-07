# frozen_string_literal: true

class CreateUserRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :user_relationships do |t|
      t.bigint :follower_id, null: false
      t.bigint :followed_id, null: false

      t.timestamps
    end

    add_index :user_relationships, :follower_id
    add_index :user_relationships, :followed_id
    add_index :user_relationships, %i[follower_id followed_id], unique: true

    add_foreign_key :user_relationships, :users, column: :follower_id
    add_foreign_key :user_relationships, :users, column: :followed_id
  end
end
