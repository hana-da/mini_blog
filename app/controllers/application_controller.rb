# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :http_basic_authenticate_for_production
  before_action :devise_permitted_parameters, if: :devise_controller?

  protected def http_basic_authenticate_for_production
    return unless Rails.env.production?

    http_basic_authenticate_or_request_with name:     ENV.fetch('BASIC_AUTH_USERNAME'),
                                            password: ENV.fetch('BASIC_AUTH_PASSWORD')
  end

  protected def devise_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[username email profile blog_url]
    devise_parameter_sanitizer.permit :sign_in, keys: %i[username]
  end
end
