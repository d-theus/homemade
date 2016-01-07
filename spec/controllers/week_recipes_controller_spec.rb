require 'rails_helper'

RSpec.describe WeekRecipesController, type: :controller do
  before(:all) { FactoryGirl.create(:week_recipes) }
  let(:json)   { JSON.parse! response.body }

  describe '#new' do
    it 'is not available' do
      expect { get :new }
      .to raise_error ActionController::UrlGenerationError
    end
  end

  describe '#destroy' do
    it 'is not available' do
      expect { delete :destroy, id: WeekRecipes.last.id }
      .to raise_error ActionController::UrlGenerationError
    end
  end

  describe '#show' do
    it 'is not available' do
      expect { get :show, id: WeekRecipes.last.id }
      .to raise_error ActionController::UrlGenerationError
    end
  end

  describe '#edit' do
    it 'is not available' do
      expect { get :edit, id: WeekRecipes.last.id }
      .to raise_error ActionController::UrlGenerationError
    end
  end

  describe '#index' do
    before { get :index }
    it 'responds with json' do
      expect(json).to have_key('recipes')
    end

    it 'has exactly 5 items in it' do
      expect(json['recipes'].size).to eq 5
    end
  end

  describe '#update' do
    it_requires_authentication :put, :update, id: WeekRecipes.last
  end
end
