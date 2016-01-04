class InventoryItem < ActiveRecord::Base
  has_and_belongs_to_many :recipes
  mount_uploader :image, ItemImageUploader
  validates :name, presence: true
  validates :image, presence: true
end
