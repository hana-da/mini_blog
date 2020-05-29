# frozen_string_literal: true

class BlogImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  def content_type_whitelist
    %w[image/]
  end

  version :thumb do
    resize_to_fit(nil, 300)
  end
end
