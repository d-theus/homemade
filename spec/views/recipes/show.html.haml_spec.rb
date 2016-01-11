require 'rails_helper'

RSpec.describe "recipes/show", type: :view do
  before(:all) { FactoryGirl.create(:recipe, title: 'Awesome title', subtitle: 'outstanding') }
  let(:title) { 'Awesome title' }
  let(:recipe) { Recipe.last }
  before { assign :recipe, recipe }
  subject { rendered }

  context 'indifferent to authorization' do
    before { allow_any_instance_of(ApplicationHelper).to receive(:admin?).and_return(nil) }
    before { render }

    it { is_expected.not_to have_css '[href^="tel:"]' }

    it { is_expected.to have_selector('title', text: title)}
    it { is_expected.to have_selector('meta[name="description"]') }
    it { is_expected.to have_selector('h1', text: title) }
    it { is_expected.to have_selector('h2', text: 'outstanding') }

    it { is_expected.to have_selector('img', text: title) }
  end

  context 'not authorized' do
    before { allow_any_instance_of(ApplicationHelper).to receive(:admin?).and_return(false) }
    before { render }
    it { is_expected.not_to have_css %Q([href="#{edit_recipe_path(recipe)}"]) }
    it { is_expected.not_to have_css %Q([href="#{recipe_path(recipe)}"]) }
  end

  context 'authorized' do
    before { allow_any_instance_of(ApplicationHelper).to receive(:admin?).and_return(true) }
    before { render }

    it { is_expected.to have_css %Q([href="#{edit_recipe_path(recipe)}"]) }
    it { is_expected.to have_css %Q([href="#{recipe_path(recipe)}"]) }
  end
end
