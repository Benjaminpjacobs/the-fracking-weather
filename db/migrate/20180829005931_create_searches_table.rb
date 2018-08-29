class CreateSearchesTable < ActiveRecord::Migration[5.2]
  def change
    create_table :searches do |t|
      t.string :query
      t.float :latitude
      t.float :longitude
      t.jsonb :cached_weather
      t.string :previous, array: true, default: []
      t.string :city
      t.string :state
      t.string :country
      t.string :zipcode
    end
  end
end
