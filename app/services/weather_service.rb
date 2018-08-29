class WeatherService
  def initialize(search)
    @key = ENV["WEATHER_API_KEY"]
    @search = search
  end

  def self.get_weather_for(search)
    service = new(search)
    service.set_coordinates
    service.set_url
    service.get_weather
  end

  def get_weather
    HTTParty.get(@url).with_indifferent_access
  end

  def set_url
    @url = "http://api.wunderground.com/api/#{@key}/conditions/q/#{@coordinates}.json"
  end

  def set_coordinates
    @coordinates = @search.to_coordinates.join(',')
  end
end