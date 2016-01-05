class Recipe < ActiveRecord::Base
  has_many :inventory_items, through: :inventory_items_recipes
  has_many :inventory_items_recipes, class_name: 'InventoryItemsRecipes'
  validates_associated :inventory_items

  validates :title, presence: true, length: { within: 2..25}
  validates :calories, presence: true, inclusion: { within: 0..3000 }
  validates :cooking_time, presence: true, inclusion: { within: 0..180 }
end
