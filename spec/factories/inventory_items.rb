FactoryGirl.define do
  factory :inventory_item do
    sequence(:name) do |n|
      "Inventory Item ##{n}"
    end

    sequence(:filename) do |n|
      "basename_#{n}"
    end
  end
end
