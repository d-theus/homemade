require 'rails_helper'

RSpec.describe Recipe, type: :model do
  describe 'Validations:' do
    it 'requires title' do
      recipe = FactoryGirl.build :recipe
      recipe.title = nil
      expect(recipe).not_to be_valid
    end

    it 'does not require subtitle' do
      recipe = FactoryGirl.build :recipe
      recipe.subtitle = nil
      expect(recipe).to be_valid
    end

    it 'requires calories to be, to be within 0..3000' do
      recipe = FactoryGirl.build :recipe
      recipe.calories = nil
      expect(recipe).not_to be_valid
      recipe.calories = -1
      expect(recipe).not_to be_valid
      recipe.calories = 0
      expect(recipe).to be_valid
      recipe.calories = 1200
      expect(recipe).to be_valid
      recipe.calories = 2999
      expect(recipe).to be_valid
    end

    it 'requires time to be, to be within 0..180 minutes' do
      recipe = FactoryGirl.build :recipe
      recipe.cooking_time = nil
      expect(recipe).not_to be_valid
      recipe.cooking_time = -1
      expect(recipe).not_to be_valid
      recipe.cooking_time = 0
      expect(recipe).to be_valid
      recipe.cooking_time = 25
      expect(recipe).to be_valid
      recipe.cooking_time = 179
      expect(recipe).to be_valid
    end

    it 'requires valid inventory items' do
      recipe = FactoryGirl.build :recipe
      expect(recipe).to be_valid
      recipe.inventory_items.push FactoryGirl.build :inventory_item_with_no_name_and_image
      expect(recipe).not_to be_valid
    end

    it 'passes when everything present' do
      recipe = FactoryGirl.build :recipe
      expect(recipe).to be_valid
    end
  end
end
