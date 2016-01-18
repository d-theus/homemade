FactoryGirl.define do
  factory :order do
    payment_method "cash"
    sequence(:customer_id) do
      Customer.order('RANDOM()').first.id
    end
    sequence(:count) { [3,5].sample }
    status "new"

    factory :order_with_customer do
      before(:create) do |record|
        c = FactoryGirl.create :customer
        record.customer_id = c.id
      end
    end
  end
end
