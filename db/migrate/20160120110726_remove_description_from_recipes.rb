class RemoveDescriptionFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :description
  end
end
