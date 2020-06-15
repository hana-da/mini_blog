# frozen_string_literal: true

class MiniBlogController < ApplicationController
  # 全体タイムライン
  def root
    @blogs = Blog.for_timeline
  end
end
