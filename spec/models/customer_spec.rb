require 'rails_helper'

RSpec.describe Customer, type: :model do
  describe 'record validation for' do
    describe 'fully valid record' do
      it 'returns true' do
        expect(FactoryGirl.build(:customer).valid?).to be_truthy
      end
    end
    describe '.name' do
      it 'fails with no name' do
        expect(FactoryGirl.build(:customer, name: nil).valid?)
        .to be_falsy
      end
      it 'fails with empty' do
        expect(FactoryGirl.build(:customer, name: '').valid?)
        .to be_falsy
      end
    end
    describe '.phone' do
      it 'fails with no phone' do
        expect(FactoryGirl.build(:customer, phone: nil).valid?)
        .to be_falsy
      end
      it 'fails with empty' do
        expect(FactoryGirl.build(:customer, phone: '').valid?)
        .to be_falsy
      end
      it 'fails with not unique phone' do
        c1 = FactoryGirl.build(:customer, phone: '+70001234567')
        expect(c1.valid?).to be_truthy
        expect(c1.save).to be_truthy
        c2 = FactoryGirl.build(:customer, phone: '+70001234567')
        expect(c2.valid?).to be_falsy
      end
      it 'fails when format is bad' do
        expect(FactoryGirl.build(:customer, phone: '2048034').valid?)
        .to be_falsy
        expect(FactoryGirl.build(:customer, phone: 'askldfjaklsdf').valid?)
        .to be_falsy
        expect(FactoryGirl.build(:customer, phone: '+100022233344').valid?)
        .to be_falsy
        expect(FactoryGirl.build(:customer, phone: '+1000223344').valid?)
        .to be_falsy
      end
    end
    describe '.address' do
      it 'fails with no address' do
        expect(FactoryGirl.build(:customer, address: nil).valid?)
        .to be_falsy
      end
      it 'fails with empty' do
        expect(FactoryGirl.build(:customer, address: '').valid?)
        .to be_falsy
      end
    end
  end
end
