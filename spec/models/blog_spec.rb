# frozen_string_literal: true

# == Schema Information
#
# Table name: blogs
#
#  id         :bigint           not null, primary key
#  content    :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

RSpec.describe Blog, type: :model do
  describe 'validations' do
    it do
      expect(Blog.new).to validate_length_of(:content).is_at_least(1).is_at_most(140)
    end
  end
end
