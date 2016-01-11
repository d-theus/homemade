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
      sequence(:day) do |n|
        if Recipe.where.not(day: nil).count > 4
          nil
        else
          day = nil
          begin
            day = rand(5) + 1
          end until (Recipe.where(day: day).count == 0)
          day
        end
      end
    end
  end
end
