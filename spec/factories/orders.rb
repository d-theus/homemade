FactoryGirl.define do
  factory :order do
    payment_method "cash"
    sequence(:count) { [3,5].sample }
    status "new"
    sequence(:interval) {
      b = rand(8)
      "#{b}-#{b+3}"
    }
    sequence(:customer_id) do
      c = FactoryGirl.create :customer
      c.id
    end
  end
end
