INVENTORY_ITEM_IMAGES = {
  'нож и доска' => 'knife.svg',
  'миска' => 'plate.svg',
  'несколько мисок' => 'plates.svg',
  'сотейник' => 'stewpan.svg',
  'кастрюля' => 'pot.svg',
  'сковорода' => 'pan.svg'
}
INVENTORY_ITEMS = INVENTORY_ITEM_IMAGES.keys

FactoryGirl.define do

  factory :inventory_item do
    image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'knife.svg')) }

    sequence(:name) do |n|
      "Inventory Item ##{n}"
    end

    factory :inventory_item_with_no_name do
      name nil
      image 'lol'
    end

    factory :inventory_item_with_no_image do
      name 'random'
      image nil
    end

    factory :inventory_item_with_no_name_and_image do
      name nil
      image nil
    end

    factory :inventory_item_with_jpg_image do
      name "random"
      image { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'meal-1.jpg')) }
    end

    factory :inventory_items_for_landing do
      sequence(:name) do |n|
        INVENTORY_ITEMS[n-1]
      end
      sequence(:image) do |n|
        Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'spec', 'support', 
                    INVENTORY_ITEM_IMAGES[INVENTORY_ITEMS[n-1]]))
      end
    end
  end
end
