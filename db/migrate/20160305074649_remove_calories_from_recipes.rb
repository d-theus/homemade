class RemoveCaloriesFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :calories
  end
end
