FactoryGirl.define do
  factory :customer do
    name "Сергей Беляков"
    sequence(:phone) { |n| "+7#{1*(10**9) + n}" }
    address "ул. Просвещения, д. 20"
  end
end
