# frozen_string_literal: true

CarrierWave.configure do |config|
  config.cache_storage = :file

  case Rails.env
  when 'test'
    config.storage = :file
    config.enable_processing = false
  end
end
