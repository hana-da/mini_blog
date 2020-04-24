# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs do |t|
      t.text :content, null: false

      t.timestamps
    end
  end
end
