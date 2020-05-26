# frozen_string_literal: true

class BlogImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  version :thumb do
    resize_to_fit(nil, 300)
  end
end
