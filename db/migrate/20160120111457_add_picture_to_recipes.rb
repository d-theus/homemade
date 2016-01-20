class AddPictureToRecipes < ActiveRecord::Migration
  def change
    add_column :recipes, :picture, :string, null: false
  end
end
