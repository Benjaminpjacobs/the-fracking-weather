class SearchesController < ApplicationController
  before_action :set_new_search, only: [:index, :create]
  before_action :set_previous_searches, only: [:index, :create]

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
    @previous_searches = Search.order(query: :asc)
  end
end