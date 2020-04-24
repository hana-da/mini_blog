# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'MiniBlogControllers', type: :feature do
  describe 'root access' do
    it do
      visit root_path

      expect(page).to have_http_status(:success)
    end
  end
end
