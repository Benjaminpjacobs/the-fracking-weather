class SearchesController::CreateSearch
  attr_reader :error, :search_presenter, :query_params
  
  def self.call(query_params)
    new(query_params).call
  end

  def initialize(query_params)
    @query_params = query_params
  end
  
  def call
    validate_params or return self
    set_results or return self
    set_current_search
    cache_weather_data
    increment_count
    set_presenter
    return self
  end

  def set_presenter
    @search_presenter = SearchesController::SearchPresenter.new(@current_search)
  end

  def increment_count
    @current_search.increment_count
  end

  def cache_weather_data
    if @current_search.cached_weather.blank? || (Time.now - @current_search.updated_at) > 21600
      @weather = WeatherService.get_weather_for(@current_search)
      @current_search.update(cached_weather: @weather)
    end    
  end

  def set_current_search
    coordinates            = @results.first.coordinates
    @current_search        = Search.find_by(query_params)
    @current_search      ||= Search.near(coordinates, 5).first
    @current_search      ||= Search.create(query_params) 
  end

  def set_results
    @results = Geocoder.search(query_params[:query])
    unless @results.any?
      @error = "Fracking Try Again!"
      return false
    end
    return true
  end

  def validate_params
    unless query_params[:query].present?
      @error = "You Gotta Fracking Ask Me Something!"
      return false
    end
    return true
  end
end