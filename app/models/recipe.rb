class Recipe < ActiveRecord::Base
  has_many :inventory_items, through: :inventory_items_recipes
  has_many :inventory_items_recipes, class_name: 'InventoryItemsRecipes'
  validates_associated :inventory_items
  before_destroy :assert_no_day

  validates :title, presence: true, length: { within: 2..25}
  validates :serving_size, presence: true
  validates :cooking_time, presence: true, inclusion: { within: 0..180 }
  validates :day, uniqueness: true, inclusion: { within: 1..5 }, allow_nil: true
  validates :photo, presence: true
  validates :picture, presence: true

  scope :featured, ->{ where('day IN (1,2,3,4,5)') }


  mount_uploader :photo, RecipePhotoUploader
  mount_uploader :picture, RecipePictureUploader

  def featured?
    !self.day.nil?
  end

  private
  
  def assert_no_day
    if self.day.nil?
      true
    else
      self.errors[:day] = 'назначен'
      false
    end
  end
end
