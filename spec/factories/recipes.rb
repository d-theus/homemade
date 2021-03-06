FactoryGirl.define do
  factory :recipe do
    title { 'Lorem ipsum' }
    subtitle { 'dolor sit amet' }
    cooking_time 25
    serving_size '450 гр.'
    photo { Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'meal-1.jpg'))}
    picture { Rack::Test::UploadedFile.new( File.join(Rails.root, 'spec', 'support', "recipe-picture.jpg")) }

    factory :recipe_with_day do
      sequence(:day) do |n|
        if Recipe.where.not(day: nil).count > 4
          nil
        else
          day = nil
          begin
            day = rand(5) + 1
          end until (Recipe.where(day: day).count == 0)
          day
        end
      end
    end

    factory :recipe_for_landing do
      sequence(:title) do
        ["Lorem ipsum",
         "Dolor sit Amet" ,
         "consectetur adipiscing",
         "Duis id",
         "Pretium purus",
         "Donec iaculis est"].sample
      end
      sequence(:subtitle) do
        ["Lorem ipsum",
         "" ,
         "consectetur adipiscing elit",
         "",
         "Pretium purus",
         "Donec iaculis est"].sample
      end
      sequence(:cooking_time) { 25 + rand(20) }
      sequence(:serving_size) { "#{300 + rand(200)} гр." }
      sequence(:day)  { |n| n } 
      sequence(:photo) do |n|
        Rack::Test::UploadedFile.new(
          File.join(Rails.root, 'spec', 'support', "meal-#{n}.jpg"))
      end
      after :create do |rec|
        rec.inventory_items << InventoryItem.order('RANDOM()').limit(4)
      end
    end
  end
end
