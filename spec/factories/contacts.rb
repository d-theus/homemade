FactoryGirl.define do
  factory :contact do
    sequence(:topic) { %w(уязвимость вопрос предложение).sample }
    sequence(:text) { %w(lorem ipsum dolor sit amet).sample(5).*(10).join(' ') }
    sequence(:email) { %w(alex askljdf_01 asldfkj06 sdf.909 asdf.asf).zip(%w(mail.ru gmail.com inbox.ru rambler.ru yandex.ru).sample(5)).map { |pair| "#{pair[0]}@#{pair[1]}" }.sample }
  end
end
