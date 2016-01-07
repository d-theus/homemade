class AddDayToWeekRecipes < ActiveRecord::Migration
  def change
    add_column :week_recipes, :day, :integer, unique: true
  end
end
