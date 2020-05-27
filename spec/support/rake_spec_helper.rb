# frozen_string_literal: true

RSpec.configure do |config|
  config.define_derived_metadata(file_path: %r{/spec/lib/tasks/}) do |metadata|
    metadata[:type] = :rake
  end

  config.before :each, type: :rake do
    # Rails.application.load_tasks は before :suite でやりたいので rails_helper.rb でしています

    # 複数回タスクを呼べるように各タスクの実行回数をリセットする
    Rake.application.tasks.each(&:reenable)
  end
end
