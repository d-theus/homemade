class InventoryItem < ActiveRecord::Base
  has_many :recipes, through: :inventory_items_recipes
  has_many :inventory_items_recipes, class_name: 'InventoryItemsRecipes', dependent: :restrict_with_error
  mount_uploader :image, ItemImageUploader
  validates :name, presence: true
  validates :image, presence: true
end
