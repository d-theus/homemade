FactoryGirl.define do
  factory :callback, class: PhoneCallback do
    sequence(:name) { %w(Иван Мария Андрей Валентина Михаил Светлана).sample }
    sequence(:phone) { |n| "7#{1*(10**9) + n}" }
  end
end
