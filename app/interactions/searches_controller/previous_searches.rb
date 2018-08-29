class SearchesController::PreviousSearches
  attr_reader :params
  def self.call(params)
    new(params).call
  end

  def initialize(params)
    @params = params
  end

  def call
    set_sorters
    return_query
  end
  
  def return_query
    case @order
    when :query
      Search.limit(50).order(query: @direction)
    when :updated_at
      Search.limit(50).order(updated_at: @direction)
    when :count
      Search.limit(50).select('searches.*, array_length(previous,1) as count').group('searches.id, count').order("count #{@direction.to_s}")
    end
  end

  def set_sorters
    @order     = params[:sort_by].present? ? params[:sort_by].to_sym : :query
    @direction = params[:sort_direction].present? ? params[:sort_direction].to_sym : :asc
  end
end