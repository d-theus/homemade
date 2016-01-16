require 'rails_helper'

RSpec.describe Order, type: :model do
  before(:all) { Customer.delete_all && FactoryGirl.create(:customer) }

  describe 'attribute validation of' do
    describe '.customer' do
      it 'fails without customer' do
        expect(FactoryGirl.build(:order, customer: nil).valid?)
        .to be_falsy
      end
      it 'passes with existent customer' do
        expect(FactoryGirl.build(:order, customer: Customer.first).valid?)
        .to be_truthy
      end
    end

    describe '.payment_method' do
      it 'fails with no payment method' do
        expect(FactoryGirl.build(:order, payment_method: nil).valid?)
        .to be_falsy
      end
      it 'fails with payment methon which is not in the list' do
        expect(FactoryGirl.build(:order, payment_method: 'cash').valid?)
        .to be_truthy
        expect(FactoryGirl.build(:order, payment_method: 'card').valid?)
        .to be_truthy
      end
    end

    describe '.count' do
      it 'fails with no count' do
        expect(FactoryGirl.build(:order, count: nil).valid?)
        .to be_falsy
      end

      it 'fails with count not in (3,5)' do
        expect(FactoryGirl.build(:order, count: 4).valid?)
        .to be_falsy
      end

      it 'succeeds with count of 3' do
        expect(FactoryGirl.build(:order, count: 3).valid?)
        .to be_truthy
      end

      it 'succeeds with count of 5' do
        expect(FactoryGirl.build(:order, count: 5).valid?)
        .to be_truthy
      end
    end
  end

  describe 'status' do
    describe 'new ->' do
      let(:rec) { FactoryGirl.create :order, status: 'new'}

      it 'paid fails' do
        rec.update(payment_method: 'card')
        expect(rec.can_change_status_to?('paid')).to be_falsy
        expect(rec.pay).to be_falsy
        rec.update(payment_method: 'cash')
        expect(rec.can_change_status_to?('paid')).to be_falsy
        expect(rec.pay).to be_falsy
      end
      it 'pending succeeds' do
        rec.update(payment_method: 'card')
        expect(rec.can_change_status_to?('pending')).to be_truthy
      end
      it 'cancelled succeeds' do
        expect(rec.can_change_status_to?('closed')).to be_truthy
        expect(rec.cancel).to be_truthy
      end
      it 'closed succeeds' do
        expect(rec.can_change_status_to?('cancelled')).to be_truthy
        expect(rec.close).to be_truthy
      end
    end

    describe 'pending ->' do
      let(:rec) do
        ord = FactoryGirl.create :order, status: 'new'
        ord.update(status: 'pending')
        ord
      end

      it 'cancelled is ok' do
        expect(rec.can_change_status_to?('cancelled')).to be_truthy
        expect(rec.cancel).to be_truthy
      end
      it 'closed fails' do
        expect(rec.can_change_status_to?('closed')).to be_falsy
        expect(rec.close).to be_falsy
      end
      it 'paid succeeds' do
        expect(rec.can_change_status_to?('paid')).to be_truthy
        expect(rec.pay).to be_truthy
      end
    end

    describe 'paid ->' do
      let(:rec) do
        ord = FactoryGirl.create :order, status: 'new'
        ord.update(status: 'paid')
        ord
      end

      it 'cancelled is ok' do
        expect(rec.can_change_status_to?('cancelled')).to be_truthy
        expect(rec.cancel).to be_truthy
      end
      it 'closed is ok' do
        expect(rec.can_change_status_to?('closed')).to be_truthy
        expect(rec.close).to be_truthy
      end
    end

    describe 'cancelled ->' do
      let(:rec) do
        ord = FactoryGirl.create :order
        ord.update(status: 'cancelled')
        ord
      end

      it 'closed fails' do
        expect(rec.can_change_status_to?('closed')).to be_falsy
        expect(rec.close).to be_falsy
      end
      it 'paid is fails' do
        expect(rec.can_change_status_to?('paid')).to be_falsy
        expect(rec.pay).to be_falsy
      end
    end
    describe 'closed ->' do
      let(:rec) do
        ord = FactoryGirl.create :order
        ord.update(status: 'closed')
        ord
      end

      it 'paid fails' do
        expect(rec.can_change_status_to?('paid')).to be_falsy
        expect(rec.pay).to be_falsy
      end
      it 'cancelled fails' do
        expect(rec.can_change_status_to?('cancelled')).to be_falsy
        expect(rec.cancel).to be_falsy
      end
    end
  end

  describe '#create' do
    it 'with status = new is ok' do
      expect(FactoryGirl.create(:order, status: 'new'))
      .to be_truthy
    end
    it 'with other status fails' do
      %w(paid cancelled closed).each do |st|
        expect {FactoryGirl.create(:order, status: st)}
        .to raise_error ActiveRecord::RecordInvalid
      end
    end
  end

  describe '#destroy' do
    let(:order) { FactoryGirl.create(:order) }
    it 'with status = new fails' do
      expect(order.destroy).to be_falsy
    end
    it 'with status = paid fails' do
      order.update(status: 'paid')
      expect(order.destroy).to be_falsy
    end
    it 'with status = cancelled succeeds' do
      order.update(status: 'cancelled')
      expect(order.destroy).to be_truthy
    end
    it 'with status = closed succeeds' do
      order.update(status: 'closed')
      expect(order.destroy).to be_truthy
    end
  end
end
