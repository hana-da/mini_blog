# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlogImageUploader do
  it '画像以外のファイルは受けつけない' do
    expect { BlogImageUploader.new.store!(File.open('README.md')) }.to raise_error(CarrierWave::IntegrityError)
  end
end
