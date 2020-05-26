# frozen_string_literal: true

class BlogImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave
end
