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
    @current_search = Search.find(params[:id])
    if @current_search.cached_weather.blank? || (Time.now - @current_search.updated_at) > 21600
      @weather = WeatherService.get_weather_for(@current_search)
      @current_search.update(cached_weather: @weather)
    end
    @current_search.increment_count
    @search_presenter = SearchPresenter.new(@current_search)
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
    order     = params[:sort_by].present? ? params[:sort_by].to_sym : :query
    direction = params[:sort_direction].present? ? params[:sort_direction].to_sym : :asc
      
    @previous_searches = case order
    when :query
      Search.limit(50).order(query: direction)
    when :updated_at
      Search.limit(50).order(updated_at: direction)
    when :count
      Search.limit(50).select('searches.*, array_length(previous,1) as count').group('searches.id, count').order("count #{direction.to_s}")
    end
  end
end