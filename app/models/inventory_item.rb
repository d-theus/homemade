class InventoryItem < ActiveRecord::Base
  has_many :recipes, through: :inventory_items_recipes
  has_many :inventory_items_recipes, class_name: 'InventoryItemsRecipes', dependent: :restrict_with_error
  validates :name, presence: true
  validates :filename, presence: true, length: { minimum: 2 }

  def image
    o = OpenStruct.new
    o.svg = "aids/#{filename}.svg"
    o.png = "aids/#{filename}.png"
    o
  end
end
