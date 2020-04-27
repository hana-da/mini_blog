# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :devise_permitted_parameters, if: :devise_controller?

  protected def devise_permitted_parameters
    added_attrs = %i[username profile blog_url]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end
end
