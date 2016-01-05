require 'rails_helper'

RSpec.describe InventoryItem, type: :model do
  describe 'Validation' do
    it 'fails with no name' do
      item = FactoryGirl.build :inventory_item_with_no_name
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'fails with no image' do
      item = FactoryGirl.build :inventory_item_with_no_image
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'fails with no name and image' do
      item = FactoryGirl.build :inventory_item_with_no_name_and_image
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'fails with jpg image' do
      item = FactoryGirl.build :inventory_item_with_jpg_image
      expect { item.save! }.to raise_error ActiveRecord::RecordInvalid
    end

    it 'succeeds with name and svg image' do
      item = FactoryGirl.build :inventory_item
      expect { item.save! }.not_to raise_error
    end
  end

  describe '<-> Recipe' do
    context 'when there are recipes dependent' do
      let!(:recipe) { FactoryGirl.create(:recipe) }
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
end
