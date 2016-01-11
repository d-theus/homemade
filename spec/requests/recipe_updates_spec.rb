require 'rails_helper'
include Warden::Test::Helpers
Warden.test_mode!

RSpec.describe "RecipeUpdates", type: :request do
  before(:all)  { Admin.create(email: 'admin@example.com', password: 'top-secret') }
  before(:each) { login_as(Admin.first) }

  describe "PUT /recipes/:id" do
    let(:recipe) { FactoryGirl.create(:recipe) }
    before { put recipe_path(recipe), id: recipe.id, recipe: { title: 'Updated' } }

    it 'redirects to recipe' do
      expect(response).to redirect_to(recipe_path(recipe))
    end

    it 'shows flash' do
      follow_redirect!
      expect(response.body).to include(I18n.t 'flash.update.notice', resource_name: 'рецепт')
    end
  end
end
