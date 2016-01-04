FactoryGirl.define do
  sequence :inventory_item_name do |n|
    "Inventory Item ##{n}"
  end

  factory :inventory_item_with_no_name, class: InventoryItem do
    name nil
    image 'lol'
  end

  factory :inventory_item_with_no_image, class: InventoryItem do
    name 'random'
    image nil
  end

  factory :inventory_item_with_no_name_and_image, class: InventoryItem do
    name nil
    image nil
  end

  factory :inventory_item_with_jpg_image, class: InventoryItem do
    name "random"
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'meal-1.jpg')) }
  end

  factory :inventory_item do
    name { generate(:inventory_item_name) }
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'knife.svg')) }
  end
end
