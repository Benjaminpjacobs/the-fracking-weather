class SearchesController < ApplicationController
  def index
    @new_search = Search.new
  end

  def create
    results                  = Geocoder.search(query_params[:query])
    if results.any?
      coordinates            = results.first.coordinates
      @current_search        = Search.find_by(query_params)
      @current_search      ||= Search.near(coordinates, 5)
      @current_search        = Search.create(query_params) if @current_search.blank?
    end
  end

  private

  def query_params
    params.require(:search).permit(:query)
  end
end