require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'validations' do
    describe '.topic' do
      context 'when nil' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, topic: nil)).to be_valid
        end
      end

      context 'when empty' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, topic: nil)).to be_valid
        end
      end

      context 'when too long' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, topic: 'test'*150)).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, topic: 'some topic')).to be_valid
        end
      end
    end

    describe '.name' do
      context 'when too long' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, name: 'test' * 100)).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, name: 'some topic')).to be_valid
        end
      end
    end

    describe '.text' do
      context 'when nil' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, text: nil)).not_to be_valid
        end
      end

      context 'when empty' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, text: '')).not_to be_valid
        end
      end

      context 'when too long' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, text: 'some text' * 10000)).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, text: 'some topic' * 100)).to be_valid
        end
      end
    end

    describe '.email' do
      context 'when nil' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, email: nil)).not_to be_valid
        end
      end
      context 'when empty' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, email: '')).not_to be_valid
        end
      end

      context 'when invalid format' do
        it 'is invalid' do
          expect(FactoryGirl.build(:contact, email: 'userexample.com')).not_to be_valid
          expect(FactoryGirl.build(:contact, email: 'userexample@')).not_to be_valid
          expect(FactoryGirl.build(:contact, email: '@')).not_to be_valid
        end
      end

      context 'when valid' do
        it 'is valid' do
          expect(FactoryGirl.build(:contact, email: 'user@example.com')).to be_valid
        end
      end
    end
  end

  describe '#unread?' do
    let(:contact) { FactoryGirl.create(:contact) }
    context 'when just created' do
      it 'is true' do
        expect(contact.unread?).to be_truthy
        expect(contact).to be_unread
      end
    end

    context 'when explicitly set "read"' do
      it 'is true' do
        expect(contact.read).to be_truthy
        expect(contact.unread?).to be_falsy
        expect(contact).not_to be_unread
      end
    end
  end

  context 'nil topic' do
    subject { ct = FactoryGirl.build(:contact, topic: nil); ct.save; ct.reload; ct.topic }
    it { is_expected.to eq "без темы" }
  end
  context 'empty topic' do
    subject { ct = FactoryGirl.build(:contact, topic: ''); ct.save; ct.reload; ct.topic }
    it { is_expected.to eq "без темы" }
  end
end
