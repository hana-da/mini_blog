# frozen_string_literal: true

# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  image      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           default(0), not null
#
# Indexes
#
#  index_blogs_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :blog do
    content { generate(:quote_140) }
    user
  end
end
