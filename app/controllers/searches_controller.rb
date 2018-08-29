class SearchesController < ApplicationController
  def index
    @new_search = Search.new
  end

  def create
    results                  = Geocoder.search(query_params[:query])
    if results.any?
      coordinates            = results.first.coordinates
      @current_search        = Search.find_by(query_params)
      @current_search      ||= Search.near(coordinates, 5).first
      @current_search      ||= Search.create(query_params) 
      if @current_search.cached_weather.blank? || (Time.now - @current_search.updated_at) > 21600
        @weather = HTTParty.get("http://api.wunderground.com/api/219e5c357c3ed2dd/conditions/q/#{@current_search.to_coordinates.join(',')}.json").with_indifferent_access
        @current_search.update(cached_weather: @weather)
      end
      @new_search = Search.new
      render "index"
    end
  end

  private

  def query_params
    params.require(:search).permit(:query)
  end
end