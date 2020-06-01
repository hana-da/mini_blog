# frozen_string_literal: true

module MiniBlog
  module RSpec
    module FeatureSpecHelper
      # js の view ファイルなどで escape_javascript された文字列を適当に元に戻す。
      # 当然 JavaScript としては Syntax Error な文字列になる。
      #
      # @see ActionView::Helpers::JavaScriptHelper#escape_javascript
      #
      # @param [String] escaped_string
      # @return [String]
      def unescape(escaped_string)
        escaped_string.gsub(%r{(\\"|\\'|\\/|\\n)},
                            %q(\") => '"',
                            %q(\') => "'",
                            %q(\/) => '/',
                            '\\n'  => "\n")
      end
    end
  end
end

RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :feature
  config.include MiniBlog::RSpec::FeatureSpecHelper, type: :feature
end
