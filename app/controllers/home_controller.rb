class HomeController < ApplicationController
  def index
    @tags = ActsAsTaggableOn::Tag.most_used
  end
end
