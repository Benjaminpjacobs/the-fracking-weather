class Search < ApplicationRecord
  validates_presence_of :query
  after_validation :geocode
  after_validation :reverse_geocode
  geocoded_by :query
  reverse_geocoded_by :latitude, :longitude do |obj, results|
    if geo = results.first
      obj.city    = geo.city
      obj.state   = geo.state
      obj.country = geo.country
      obj.zipcode = geo.postal_code
    end
  end

  def count
    previous.count
  end
end
