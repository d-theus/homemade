FactoryGirl.define do
  factory :order do
    payment_method "cash"
    sequence(:customer_id) do
      Customer.order('RANDOM()').first.id
    end
    sequence(:count) { [3,5].sample }
    state "new"
  end
end
