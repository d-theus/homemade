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
end
