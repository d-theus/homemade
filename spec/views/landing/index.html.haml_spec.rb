require 'rails_helper'

RSpec.describe "landing/index.html.haml", type: :view do
  before(:all) { Recipe.delete_all}
  before(:all) { InventoryItem.delete_all }
  before(:all) { 6.times { FactoryGirl.create(:inventory_items_for_landing)}}
  before(:all) { 5.times { FactoryGirl.create(:recipe_for_landing)}}
  before(:each) { allow_any_instance_of(ApplicationHelper)
                  .to receive(:admin?).and_return(false) }

  context 'when there are 5 featured recipes' do
    before(:each) { assign(:recipes, Recipe.featured) }
    before(:each) { render template: 'landing/index', layout: 'layouts/application' }

    it 'has meta-description' do
      expect(rendered).to have_selector 'meta[name="description"]'
    end
    it 'has meta-keywords' do
      expect(rendered).to have_selector 'meta[name="keywords"]'
    end
    it 'has phone' do
      expect(rendered).to have_css %Q(a[href^="tel:"])
    end
    it 'has offer link', pending: true do
      expect(rendered).to have_link 'Оферта', href: offer_path
    end
    it 'has policy link', pending: true do
      expect(rendered).to have_link 'Конфиденциальность', href: policy_path
    end

    it 'has no stub' do
      expect(rendered).not_to have_css('#stub')
    end
    it 'has exactly 5 recipes' do
      expect(rendered).to have_css %Q(a[href^="/recipes/"]), count: 5
    end
  end

  context 'when there are no 5 featured recipes' do
    before { Recipe.featured.first.update(day: nil) }
    before { assign(:recipes, Recipe.featured) }
    before { render template: 'landing/index', layout: 'layouts/application' }

    it 'has stub' do
      expect(Recipe.featured.count).to eq 4
      expect(rendered).to have_css('#stub')
    end

    it 'has no recipes' do
      expect(Recipe.featured.count).to eq 4
      expect(rendered).not_to have_css %Q(a[href^="/recipes/"])
    end
  end
end
