# frozen_string_literal: true

class CreateBlogs < ActiveRecord::Migration[6.0]
  def change
    create_table :blogs, &:timestamps
  end
end
