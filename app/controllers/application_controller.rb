# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :devise_permitted_parameters, if: :devise_controller?

  protected def devise_permitted_parameters
    devise_parameter_sanitizer.permit :sign_up, keys: %i[username profile blog_url]
    devise_parameter_sanitizer.permit :sign_in, keys: %i[username]
  end
end
