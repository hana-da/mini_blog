# frozen_string_literal: true

class MiniBlogController < ApplicationController
  def root
    @blog = Blog.new
    @blogs = Blog.includes(:user)
  end
end
