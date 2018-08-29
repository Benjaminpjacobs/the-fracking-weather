class SearchesController < ApplicationController
  def index
    @new_search = Search.new
  end
end