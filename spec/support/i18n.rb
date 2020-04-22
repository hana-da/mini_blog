# frozen_string_literal: true

# I18n.translate (aka I18n.t) の呼出しの記述を簡単にするためのヘルパーメソッド
# feature specで使うと key に相対指定のkeyが使えます
#
# @param [String] key for I18n.translate
# @param [Hash] options for I18n.translate
# @return [String]
def translate(key, options = {})
  if key.start_with?('.') && respond_to?(:current_path)
    path_parameters = Rails.application.routes.recognize_path(current_path)
    key = [
      path_parameters[:controller].tr('/', '.'),
      path_parameters[:action],
      key[1..-1],
    ].join('.')
  end
  I18n.translate(key, options)
end
alias t translate

# I18n.localize (aka I18n.l) の呼び出し記述を簡単にするためのヘルパーメソッド
#
# @param [ActiveSupport::TimeWithZone] object localize対象のobject
# @param [Hash] options localizeオプション
# @option options [String] :timezone objectのtimezoneを書き換える(default: 'Tokyo')
def localize(object, options = {})
  timezone = options[:timezone] || 'Tokyo'
  I18n.localize(object.in_time_zone(timezone), options)
end
alias l localize
