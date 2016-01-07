class AddDayToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :day, :integer, default: nil, limit: 1
    add_index  :recipes, :day, unique: true
  end
end
