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

    describe 'day' do
      before { Recipe.delete_all }

      it 'is allowed for day to be nil' do
        recipe = FactoryGirl.build :recipe, day: nil
        expect(recipe.save).to be_truthy
      end

      it 'successfully assigns days (1,2,3,4,5)' do
        5.times do |i|
          recipe =  FactoryGirl.build :recipe, day: i+1
          expect(recipe.save).to be_truthy
        end
      end

      it 'days are forced to be unique' do
        recipe1 =  FactoryGirl.build :recipe, day: 1
        recipe2 =  FactoryGirl.build :recipe, day: 1
        expect(recipe1.save).to be_truthy
        expect(recipe2.save).to be_falsy
        expect(recipe2.errors).to have_key(:day)
      end

      it 'fails when day out of range' do
        recipe =  FactoryGirl.build :recipe, day: 6
        expect(recipe.save).to be_falsy
        expect(recipe.errors).to have_key(:day)
      end

      it 'does not delete recipe with day assigned' do
        recipe =  FactoryGirl.build :recipe, day: 6
        expect(recipe.destroy).to be_falsy
        recipe =  FactoryGirl.build :recipe, day: nil
        expect(recipe.destroy).to be_truthy
      end
    end
  end

  describe '#featured?' do
    it 'returns true if day is present' do
      expect(Recipe.new(day: 5).featured?).to be_truthy
    end
    it 'returns false when day is nil' do
      expect(Recipe.new(day: nil).featured?).to be_falsy
    end
  end

  describe '<-> InventoryItem' do
    let!(:recipe) { FactoryGirl.create(:recipe_with_inventory_items) }

    it 'does not delete any dependent inventory items' do
      expect(recipe.inventory_items.count).to eq(4)
      expect {recipe.delete}.not_to change(InventoryItem, :count)
    end
  end
end
