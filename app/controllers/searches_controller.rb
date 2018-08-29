class SearchesController < ApplicationController
  before_action :set_new_search 
  before_action :set_previous_searches

  def index
  end

  def create
    validate_params or return
    results                  = Geocoder.search(query_params[:query])
    if results.any?
      coordinates            = results.first.coordinates
      @current_search        = Search.find_by(query_params)
      @current_search      ||= Search.near(coordinates, 5).first
      @current_search      ||= Search.create(query_params) 
      if @current_search.cached_weather.blank? || (Time.now - @current_search.updated_at) > 21600
        @weather = HTTParty.get("http://api.wunderground.com/api/#{ENV['WEATHER_API_KEY']}/conditions/q/#{@current_search.to_coordinates.join(',')}.json").with_indifferent_access
        @current_search.update(cached_weather: @weather)
      end
      @current_search.increment_count
    else
      @error = "Fracking Try Again!"
    end
    render "index"
  end

  def show
    @current_search = Search.find(params[:id])
    if @current_search.cached_weather.blank? || (Time.now - @current_search.updated_at) > 21600
      @weather = HTTParty.get("http://api.wunderground.com/api/#{ENV['WEATHER_API_KEY']}/conditions/q/#{@current_search.to_coordinates.join(',')}.json").with_indifferent_access
      @current_search.update(cached_weather: @weather)
    end
    @current_search.increment_count
    render "index"
  end

  def previous_searches
    render partial: 'previous_searches'
  end

  private

  def query_params
    params.require(:search).permit(:query)
  end

  def validate_params
    unless query_params[:query].present?
      @error = "You Gotta Fracking Ask Me Something!"
      render "index" and return
    end
    return true
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