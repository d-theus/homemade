require 'rails_helper'

RSpec.describe "recipes/index", type: :view do
  before(:all) { Recipe.delete_all }
  before(:all) { 150.times { FactoryGirl.create(:recipe_with_day) } }
  let(:paginated_recipes) { Recipe.paginate(page: 1, per_page: 15) }
  before { assign(:recipes, paginated_recipes) }

  before { render }
  subject { rendered }

  it { is_expected.to have_css %Q(a[name="new"][href="#{new_recipe_path}"]) }
  it { is_expected.to have_selector 'table' }
  it { is_expected.to have_selector '.recipe', count: 15 }
  it { is_expected.to have_css '.pagination' }

  context 'given not featured recipe' do
    let(:recipe) { paginated_recipes.to_a.select { |r| !r.featured?}.first }
    it { is_expected.to have_css %Q([href="#{edit_recipe_path(recipe)}"][name="edit"])}
    it { is_expected.to have_css %Q([href="#{recipe_path(recipe)}"][name="delete"])}
  end

  context 'given featured recipe' do
    let(:recipe) { paginated_recipes.to_a.select { |r| r.featured?}.first }
    it { is_expected.to have_css %Q([href="#{edit_recipe_path(recipe)}"][name="edit"])}
    it { is_expected.not_to have_css %Q([href="#{recipe_path(recipe)}"][name="delete"])}
  end
end
