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

  describe 'status change' do
    shared_examples "transition" do |param|
      let(:rec) { ord = FactoryGirl.build(:order, status: param[:from].to_s);ord.save(validate: false);ord }
      it "#{param[:from]} -> #{param[:to]} is #{param[:is]}" do
        expect(rec.can_change_status_to?(param[:to].to_s)).to (param[:is] == :ok ? be_truthy : be_falsy)
        if param[:with_method]
          expect(rec.send(param[:with_method])).to (param[:is] == :ok ? be_truthy : be_falsy)
        end
      end
    end

    it_behaves_like 'transition', from: :new, to: :paid, with: :pay, is: :not_ok
    it_behaves_like 'transition', from: :new, to: :cancelled, with: :cancel, is: :ok
    it_behaves_like 'transition', from: :new, to: :closed, with: :close, is: :not_ok
    it_behaves_like 'transition', from: :new, to: :pending, is: :ok

    it_behaves_like 'transition', from: :pending, to: :paid, with: :pay, is: :ok
    it_behaves_like 'transition', from: :pending, to: :cancelled, with: :cancel, is: :ok
    it_behaves_like 'transition', from: :pending, to: :closed, with: :close, is: :not_ok
    it_behaves_like 'transition', from: :pending, to: :awaiting_delivery, is: :not_ok

    it_behaves_like 'transition', from: :paid, to: :cancelled, with: :cancel, is: :not_ok
    it_behaves_like 'transition', from: :paid, to: :closed, with: :close, is: :not_ok
    it_behaves_like 'transition', from: :paid, to: :awaiting_refund, is: :ok
    it_behaves_like 'transition', from: :paid, to: :awaiting_delivery, is: :ok

    it_behaves_like 'transition', from: :awaiting_delivery, to: :closed, with: :close, is: :ok
    it_behaves_like 'transition', from: :awaiting_delivery, to: :cancelled, with: :cancel, is: :not_ok

    it_behaves_like 'transition', from: :awaiting_refund, to: :cancelled, with: :cancel, is: :ok
    it_behaves_like 'transition', from: :awaiting_refund, to: :closed, with: :close, is: :false
  end

  describe 'status quering:' do
    shared_examples "?-method" do |param|
      let(:rec) { ord = FactoryGirl.build(:order, status: param[:status].to_s);ord.save(validate: false);ord }
      it "##{param[:status]}? == true" do
        expect(rec.send("#{param[:status]}?")).to be_truthy
      end
    end

    it_behaves_like '?-method', status: :new
    it_behaves_like '?-method', status: :awaiting_delivery
    it_behaves_like '?-method', status: :awaiting_refund
    it_behaves_like '?-method', status: :paid
    it_behaves_like '?-method', status: :pending
    it_behaves_like '?-method', status: :closed
    it_behaves_like '?-method', status: :cancelled
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

    it 'immediately assigns status [pending] if card' do
      rec = FactoryGirl.build(:order, status: 'new', payment_method: 'card')
      expect(rec.save).to be_truthy
      expect(rec.status).to eq 'pending'
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
