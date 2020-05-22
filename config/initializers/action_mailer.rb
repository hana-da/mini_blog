# frozen_string_literal: true

Rails.application.configure do
  config.action_mailer.default_url_options = { host: ENV.fetch('DEFAULT_URL_HOST', 'localhost:3000') }
end
