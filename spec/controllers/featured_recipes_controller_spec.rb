require 'rails_helper'

RSpec.describe FeaturedRecipesController, type: :controller do
  let(:json)   { JSON.parse! response.body }
  before { Recipe.delete_all }
  before { FactoryGirl.reload }
  before { 20.times { FactoryGirl.create(:recipe) } }
  before { 5.times { FactoryGirl.create(:recipe_with_day) } }

  describe '#index' do
    before { get :index }
    it 'responds with json' do
      expect(json).to have_key('featured_recipes')
    end

    it 'has exactly 5 items in it' do
      expect(json['featured_recipes'].size).to eq 5
    end
  end
end
