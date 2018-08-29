class SearchesController::ShowSearch
  attr_reader :error, :search_presenter
  
  def self.call(id)
    new(id).call
  end

  def initialize(id)
    @current_search = Search.find_by(id: id)
  end

  def call
    validate_search or return self
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
  
  def validate_search
    if @current_search.nil?
      @error = "Something Went Wrong. Frack."
      return false
    end
    return true
  end
  
end