class SearchesController::SearchPresenter

  def initialize(search)
    @search = search
  end

  def temp
    @temp ||= search.cached_weather['current_observation']['temp_f']
  end

  def conditions
    @conditions ||= search.cached_weather['current_observation']['weather']
  end

  def location_name
    @location_name ||= "#{search.city}, #{search.state}"
  end

  def previous
    @previous ||= search.previous
  end

  def sorted_times
    @sorted_times ||= search.previous.reverse[1..-1].map do |time|
      "#{DateTime.parse(time).strftime("%I:%M %p")} on #{DateTime.parse(time).strftime("%m/%d/%y")}"
    end
  end

  private
  
  attr_reader :search
end