class RemoveFeaturedFromRecipes < ActiveRecord::Migration
  def change
    remove_column :recipes, :featured
  end
end
