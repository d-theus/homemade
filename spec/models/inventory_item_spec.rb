require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  describe 'Validation' do
    it 'fails with no name' do
      item = FactoryGirl.build :inventory_item, name: nil
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'fails with no filename' do
      item = FactoryGirl.build :inventory_item, filename: nil
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'succeeds with name and filename' do
      item = FactoryGirl.build :inventory_item
      expect { item.save! }.not_to raise_error
    end
  end

  describe '<-> Recipe' do
    xcontext 'when there are recipes dependent' do
      let!(:iis) { 4.times { FactoryGirl.create(:inventory_item) }; InventoryItem.order('created_at DESC').take(4) }
      let!(:recipe) { FactoryGirl.create(:recipe, inventory_items: iis) }
      let!(:ii) { recipe.inventory_items.first }

      it 'isnt deleted' do
        expect(recipe.inventory_items.any?).to be_truthy
        expect(ii.recipes.any?).to be_truthy
        expect { ii.destroy }.not_to change(InventoryItem, :count)
      end
    end
    context 'when there are no recipes' do
      before { FactoryGirl.create(:inventory_item) }
      let(:ii) { InventoryItem.last }

      it 'is deleted' do
        expect(ii.recipes.any?).to be_falsy
        expect(ii.delete).to be_truthy
      end
    end
  end

  describe 'image' do
    let(:ii) { FactoryGirl.create(:inventory_item) }
    subject { ii.image }

    its(:svg)
  end
end
