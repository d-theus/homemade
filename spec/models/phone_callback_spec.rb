require 'rails_helper'

RSpec.describe PhoneCallback, type: :model do
  describe 'validations' do

    describe '.name' do
      context 'when nil' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, name: nil)).not_to be_valid
        end
      end

      context 'when empty' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, name: '')).not_to be_valid
        end
      end

      context 'when too long' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, name: 'some name' * 10000)).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:callback, name: 'some name' * 3)).to be_valid
        end
      end
    end

    describe 'phone' do
      context 'when nil' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, phone: nil)).not_to be_valid
        end
      end
      context 'when empty' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, phone: '')).not_to be_valid
        end
      end

      context 'when invalid format' do
        it 'is invalid' do
          expect(FactoryGirl.build(:callback, phone: 'alskdfjlskdfj')).not_to be_valid
          expect(FactoryGirl.build(:callback, phone: '189427')).not_to be_valid
          expect(FactoryGirl.build(:callback, phone: '@')).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:callback, phone: '79111112233')).to be_valid
        end
      end
    end
  end

  describe '#pending?' do
    let(:callback) { FactoryGirl.create(:callback) }
    context 'when just created' do
      it 'is true' do
        expect(callback.pending?).to be_truthy
        expect(callback).to be_pending
      end
    end

    context 'when explicitly set "false"' do
      it 'is true' do
        expect(callback.close).to be_truthy
        expect(callback.pending?).to be_falsy
        expect(callback).not_to be_pending
      end
    end
  end
end
