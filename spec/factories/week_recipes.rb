FactoryGirl.define do
  factory :week_recipes, :class => 'WeekRecipes' do
    sequence(:day)    { |n| n % 5 + 1 }
    sequence(:recipe) { |n| Recipe.offset(n % 5 + 1).first }
  end
end
