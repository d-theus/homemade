FactoryGirl.define do
  factory :order do
    sequence(:payment_method) { %w(cash card).sample }
    sequence(:count) { [3,5].sample }
    status "new"
    sequence(:interval) { b = rand(8); "#{b}-#{b+3}" }
    sequence(:name) { %w(Александр Андрей Валентина Владимир Елена Мария Марат Светлана Сергей Ян).sample }
    sequence(:phone) { |n| "7#{1*(10**9) + n}" }
    sequence(:address) do
      streets = [
        "yл.Просвещения",
        "ул. Янгеля",
        "Сущёвский вал",
        "какой-то пр-д",
        "очень странный проезд"
      ]
      num = 1 + rand(1000)
      apt = 1 + rand(1000)
      "#{streets.sample},#{num} квартира #{apt}"
    end
  end
end
