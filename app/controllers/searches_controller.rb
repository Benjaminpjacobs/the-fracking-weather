class SearchesController < ApplicationController
  before_action :set_new_search 
  before_action :set_previous_searches

  def index; end

  def create
    creator = CreateSearch.call(query_params)
    if creator.error.present?
      @error = creator.error
    else
      @search_presenter = creator.search_presenter
    end
    render "index"
  end

  def show
    show = ShowSearch.call(params[:id])
    if show.error.present?
      @error = show.error
    else
      @search_presenter = show.search_presenter
    end
    render "index"
  end

  def previous_searches
    render partial: 'previous_searches'
  end

  private

  def query_params
    params.require(:search).permit(:query)
  end

  def set_new_search
    @new_search = Search.new
  end

  def set_previous_searches
    @previous_searches = PreviousSearches.call(params)
  end
end