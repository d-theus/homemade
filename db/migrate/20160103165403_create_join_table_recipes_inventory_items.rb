class CreateJoinTableRecipesInventoryItems < ActiveRecord::Migration
  def change
    create_join_table :recipes, :inventory_items do |t|
      #t.index [:recipe_id, :inventory_item_id]
      #t.index [:inventory_item_id, :recipe_id]
    end
  end
end
