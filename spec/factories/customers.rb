FactoryGirl.define do
  factory :customer do
    sequence(:name) do
      %w(Иван Мария Андрей Валентина Михаил Светлана).sample
    end
    sequence(:phone) { |n| "7#{1*(10**9) + n}" }
    address "ул. Просвещения, д. 20"
  end
end
