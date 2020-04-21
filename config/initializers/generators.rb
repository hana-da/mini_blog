# frozen_string_literal: true

Rails.application.config.generators do |g|
  g.assets false
  g.helper true
  g.controller skip_routes: true
  g.test_framework :rspec,
                   request_specs:    false,
                   controller_specs: false,
                   view_specs:       false,
                   routing_specs:    false,
                   helper_specs:     true,
                   fixture:          true
  g.fixture_replacement :factory_bot, dir: 'spec/factories'
end
