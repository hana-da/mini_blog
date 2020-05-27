# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'rake mini_blog:report', type: :rake do
  describe 'daily_favorite_ranking' do
    it do
      expect { Rake.application['mini_blog:report:daily_favorite_ranking'].invoke }
        .to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
