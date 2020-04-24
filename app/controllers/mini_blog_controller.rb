# frozen_string_literal: true

class MiniBlogController < ApplicationController
  def root
    @blogs = Blog.all
  end
end
