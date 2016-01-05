FactoryGirl.define do
  factory :recipe do
    title { 'Lorem ipsum' }
    subtitle { 'dolor sit amet' }
    cooking_time 25
    calories 450
    description { 'lipsum adlsfashdflk ad fjalksd fjlkasjd flkajs dkfljs kaj' }
    after :create do |rec|
      4.times do
        rec.inventory_items << FactoryGirl.create(:inventory_item)
      end
    end
  end
end
