FactoryGirl.define do
  factory :recipe do
    title { 'Lorem ipsum' }
    subtitle { 'dolor sit amet' }
    cooking_time 25
    calories 450
    description { 'lipsum adlsfashdflk ad fjalksd fjlkasjd flkajs dkfljs kaj' }

    factory :recipe_with_inventory_items do
      after :create do |rec|
        4.times do
          rec.inventory_items << FactoryGirl.create(:inventory_item)
        end
      end
    end

    factory :recipe_with_day do
      sequence(:day) { |n| n }
    end
  end
end
