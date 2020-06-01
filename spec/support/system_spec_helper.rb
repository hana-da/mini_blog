# frozen_string_literal: true

Capybara.register_driver :selenium_chrome_headless_no_sandbox do |app|
  selenium_chrome_headless = Capybara.drivers[:selenium_chrome_headless].call

  # https://blog.toshimaru.net/rails-on-docker-system-spec/#chrome-failed-to-start-exited-abnormally
  # https://github.com/teamcapybara/capybara/pull/2241
  selenium_chrome_headless.options[:options].args << '--no-sandbox'

  browser_options = selenium_chrome_headless.options[:options]

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: browser_options)
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :system

  config.before(:each, type: :system) do |e|
    driver = if e.metadata[:js]
               if Process::UID.eid.zero?
                 :selenium_chrome_headless_no_sandbox
               else
                 :selenium_chrome_headless
               end
             else
               :rack_test
             end

    driven_by driver
  end
end
