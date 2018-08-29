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

  def increment_count
    self.previous << self.updated_at.to_s
    self.save
  end

  def location_name
    "#{self.city}, #{self.state}"
  end

  def last_searched
    self.updated_at.strftime("%m/%d/%y %I:%M %p")
  end
end
