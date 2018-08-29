class AddIndexToSearches < ActiveRecord::Migration[5.2]
  def change
    add_index :searches, :query
  end
end
