# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FactoryBot do
  describe '.lint' do
    it do
      ApplicationRecord.transaction do
        expect { FactoryBot.lint }.not_to raise_error
        raise ActiveRecord::Rollback
      end
    end
  end
end
