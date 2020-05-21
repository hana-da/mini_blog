# frozen_string_literal: true

class AddEmailToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email, :string, null: false, default: ''
    add_index  :users, :email, unique: true, where: %("email" != '')
  end
end
