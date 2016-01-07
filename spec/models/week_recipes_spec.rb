require 'rails_helper'

RSpec.describe WeekRecipes, type: :model do
  before(:all)  { 10.times { FactoryGirl.create(:recipe_with_inventory_items)} }
  before(:all)  { WeekRecipes.setup }
  before(:each) { WeekRecipes.find_each { |wr| wr.recipe = Recipe.order('RANDOM()').first; redo unless wr.save } }

  describe '#all' do
    it 'returns exactly 5 results' do
      expect(WeekRecipes.all.count).to eq 5 
    end

    it 'returns recipes when recipe_id is present' do
      wr = WeekRecipes.first
      recipes = WeekRecipes.all.to_a.map(&:recipe)
      expect(recipes).to be_an Array
      expect(recipes.first).to be_a Recipe
    end
  end

  describe '#create' do
    it 'shifts and leaves 5 recipes then > 5' do
      expect { WeekRecipes.create }
      .not_to change(WeekRecipes, :count)
    end
  end

  describe '#destroy' do
    it 'shifts and leaves 5 recipes then < 5' do
      expect { WeekRecipes.last.destroy }
      .not_to change(WeekRecipes, :count)
    end

    it 'cannot affect recipe' do
      recipe = WeekRecipes.first.recipe
      expect(recipe).to be_a Recipe
      expect {WeekRecipes.first.destroy!}.not_to change(recipe, :id)
    end
  end
end
