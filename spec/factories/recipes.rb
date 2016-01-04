FactoryGirl.define do
  factory :recipe do
    title { 'Lorem ipsum' }
    subtitle { 'dolor sit amet' }
    cooking_time 25
    calories 450
    description { 'lipsum adlsfashdflk ad fjalksd fjlkasjd flkajs dkfljs kaj' }
    inventory_items do
      create_list(:inventory_item, 4)
    end
  end
end
