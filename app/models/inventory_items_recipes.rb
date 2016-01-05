class InventoryItemsRecipes < ActiveRecord::Base
  belongs_to :recipe
  belongs_to :inventory_item
end
