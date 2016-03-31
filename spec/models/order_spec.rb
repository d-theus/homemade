require 'rails_helper'

RSpec.describe Order, type: :model do
  let!(:factory) { :order }

  shared_context 'required attr' do
    it 'is invalid when nil' do
      expect(FactoryGirl.build(factory, param => nil)).not_to be_valid
    end
  end
  shared_context 'no-blank attr' do
    it 'is invalid when blank' do
      expect(FactoryGirl.build(factory, param => '')).not_to be_valid
    end
  end
  shared_context 'formatted attr' do |opts|
    it 'is invalid with bad format' do
      opts[:bad].each do |bad|
        expect(FactoryGirl.build(factory, param => bad)).not_to be_valid
      end
    end
    it 'is valid with good format' do
      opts[:good].each do |good|
        expect(FactoryGirl.build(factory, param => good)).to be_valid
      end
    end
  end

  describe 'validations:' do
    describe 'name' do
      let!(:param) { :name }

      it_behaves_like 'required attr'
      it_behaves_like 'no-blank attr'
      it_behaves_like 'formatted attr',
        good: %w(name namename somename),
        bad: [ "a"*100 , "c" ]
    end

    describe 'phone' do
      let!(:param) { :phone }

      it_behaves_like 'required attr'
      it_behaves_like 'no-blank attr'
      it_behaves_like 'formatted attr',
        good: %w(71112223344 74440000000),
        bad: [ "a"*100 , "c", "9261112233", "81112223344", "79266779116747" ]
    end

    describe 'address' do
      let!(:param) { :address }

      it_behaves_like 'required attr'
      it_behaves_like 'no-blank attr'
      it_behaves_like 'formatted attr',
        good: [ "улица Просвещения дом 20 квартира 45"],
        bad: [ "a"*300 , "c" ]
    end

    describe '.payment_method' do
      it 'fails with no payment method' do
        expect(FactoryGirl.build(:order, payment_method: nil).valid?)
        .to be_falsy
      end

      it 'succeeds with payment methon which is in the list' do
        expect(FactoryGirl.build(:order, payment_method: 'cash').valid?)
        .to be_truthy
        expect(FactoryGirl.build(:order, payment_method: 'card').valid?)
        .to be_truthy
      end

      it 'fails with payment methon which is not in the list' do
        expect(FactoryGirl.build(:order, payment_method: 'blah').valid?)
        .to be_falsy
        expect(FactoryGirl.build(:order, payment_method: 'cardcard').valid?)
        .to be_falsy
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

    describe '.interval' do
      it 'fails when absent' do
        expect(FactoryGirl.build(:order, interval: nil)).not_to be_valid
      end
      it 'fails with bad format' do
        expect(FactoryGirl.build(:order, interval: 'asdaf')).not_to be_valid
        expect(FactoryGirl.build(:order, interval: '110-13')).not_to be_valid
      end
      it 'succeeds when matches pattern' do
        expect(FactoryGirl.build(:order, interval: '10-13')).to be_valid
        expect(FactoryGirl.build(:order, interval: '13-18')).to be_valid
        expect(FactoryGirl.build(:order, interval: '18-21')).to be_valid
        expect(FactoryGirl.build(:order, interval: '10-21')).to be_valid
      end
    end
  end

  describe 'status change' do
    shared_examples "transition" do |param|
      let(:rec) do
        ord = FactoryGirl.build(:order)
        ord.save(validate: false)
        ord = Order.find(ord.id)
        ord.status = param[:from].to_s
        ord.save(validate: false)
        ord
      end

      it "#{param[:from]} -> #{param[:to]} is #{param[:is]}" do
        expect(rec.status).to eq(param[:from].to_s)
        expect(rec.can_change_status_to?(param[:to].to_s)).to (param[:is] == :ok ? be_truthy : be_falsy)
        if param[:with_method]
          expect(rec.send(param[:with_method])).to (param[:is] == :ok ? be_truthy : be_falsy)
          expect { rec.send(param[:with_method]) }.send(
            param[:is] == :ok ? :to : :not_to, change(rec, :status).from(param[:from].to_s))
        end
      end
    end

    shared_examples 'transition_method' do |param|
      let(:rec) do
        ord = FactoryGirl.build(:order)
        ord.save(validate: false)
        ord = Order.find(ord.id)
        ord.status = param[:initial].to_s
        ord.save(validate: false)
        ord
      end

      context "w/ initial state = #{param[:initial]}" do
        it "returns #{param[:is] == :ok ? :true : :false}" do
          fail ':method_name is to be defined' unless defined? method_name
          fail ':is parameter is to be defined' unless param[:is]

          expect(rec.send(method_name)).to (param[:is] == :ok ? be_truthy : be_falsy)
        end

        it "#{param[:is] == :ok ? 'changes' : 'does not change'} status from #{param[:from]} to #{param[:initial]}" do
          fail ':method_name is to be defined' unless defined? method_name
          fail ':is parameter is to be defined' unless param[:is]

          expect { rec.send(method_name) }.send(
            param[:is] == :ok ? :to : :not_to, change(rec, :status).from(param[:initial].to_s))
        end
      end
    end

    context 'w/ payment method = "cash"' do
      before { rec.payment_method = 'cash'; rec.save(validate: false) }

      it_behaves_like 'transition', from: :new, to: :paid, with: :pay, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :cancelled, with: :cancel, is: :ok
      it_behaves_like 'transition', from: :new, to: :closed, with: :close, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :pending, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :awaiting_refund, is: :not_ok

      it_behaves_like 'transition', from: :awaiting_delivery, to: :closed, with: :close, is: :ok
      it_behaves_like 'transition', from: :awaiting_delivery, to: :cancelled, with: :cancel, is: :not_ok

      it_behaves_like 'transition', from: :cancelled, to: :cancelled, with: :cancel, is: :not_ok
      describe '#make_awaiting_delivery' do
        let!(:method_name) { :make_awaiting_delivery }
        it_behaves_like 'transition_method', initial: :new, is: :ok
        it_behaves_like 'transition_method', initial: :paid, is: :not_ok
        it_behaves_like 'transition_method', initial: :pending, is: :not_ok
        it_behaves_like 'transition_method', initial: :awaiting_refund, is: :not_ok
        it_behaves_like 'transition_method', initial: :cancelled, is: :not_ok
        it_behaves_like 'transition_method', initial: :closed, is: :not_ok
      end
    end
    context 'w/ payment method = "card"' do
      before { rec.payment_method = 'card'; rec.save(validate: false) }

      it_behaves_like 'transition', from: :new, to: :paid, with: :pay, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :cancelled, with: :cancel, is: :ok
      it_behaves_like 'transition', from: :new, to: :closed, with: :close, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :pending, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :awaiting_delivery, is: :not_ok
      it_behaves_like 'transition', from: :new, to: :awaiting_refund, is: :not_ok

      it_behaves_like 'transition', from: :pending, to: :paid, with: :pay, is: :ok
      it_behaves_like 'transition', from: :pending, to: :cancelled, with: :cancel, is: :ok
      it_behaves_like 'transition', from: :pending, to: :closed, with: :close, is: :not_ok
      it_behaves_like 'transition', from: :pending, to: :awaiting_delivery, is: :not_ok
      it_behaves_like 'transition', from: :pending, to: :awaiting_refund, is: :not_ok
      it_behaves_like 'transition', from: :pending, to: :pending, is: :not_ok

      it_behaves_like 'transition', from: :paid, to: :cancelled, with: :cancel, is: :not_ok
      it_behaves_like 'transition', from: :paid, to: :closed, with: :close, is: :not_ok
      it_behaves_like 'transition', from: :paid, to: :awaiting_refund, is: :ok
      it_behaves_like 'transition', from: :paid, to: :paid, with: :pay, is: :not_ok

      it_behaves_like 'transition', from: :awaiting_delivery, to: :closed, with: :close, is: :ok
      it_behaves_like 'transition', from: :awaiting_delivery, to: :cancelled, with: :cancel, is: :not_ok

      it_behaves_like 'transition', from: :cancelled, to: :cancelled, with: :cancel, is: :not_ok

      describe '#make_awaiting_delivery' do
        let!(:method_name) { :make_awaiting_delivery }
        it_behaves_like 'transition_method', initial: :new, is: :not_ok
        it_behaves_like 'transition_method', initial: :paid, is: :ok
        it_behaves_like 'transition_method', initial: :pending, is: :not_ok
        it_behaves_like 'transition_method', initial: :awaiting_refund, is: :not_ok
        it_behaves_like 'transition_method', initial: :cancelled, is: :not_ok
        it_behaves_like 'transition_method', initial: :closed, is: :not_ok
      end
    end
  end

  describe 'status quering:' do
    shared_examples "?-method" do |param|
      let(:rec) do
        ord = FactoryGirl.build(:order, payment_method: 'cash', status: param[:status].to_s)
        ord.save!(validate: false)
        ord
      end

      it "##{param[:status]}? == true" do
        expect(rec.send("#{param[:status]}?")).to be_truthy
      end
    end

    it_behaves_like '?-method', status: :new
    it_behaves_like '?-method', status: :awaiting_delivery
    it_behaves_like '?-method', status: :awaiting_refund
    it_behaves_like '?-method', status: :pending
    it_behaves_like '?-method', status: :closed
    it_behaves_like '?-method', status: :cancelled

    describe '#paid?' do
      context 'when cash' do
        Order::STATUS_TABLE.keys.each do |st|
          it 'isnt' do
            order = FactoryGirl.create(:order)
            order.payment_method= 'cash'
            order.status= st
            order.save(validate: false)
            expect(order).not_to be_paid
          end
        end
      end
      context 'when card' do
        %w(new pending cancelled).each do |st|
          context "when status = #{st}" do
            it "isnt" do
              order = FactoryGirl.create(:order)
              order.payment_method= 'card'
              order.status= st
              order.save(validate: false)
              expect(order).not_to be_paid
            end
          end
        end
        %w(paid awaiting_delivery awaiting_refund closed).each do |st|
          context "when status = #{st}" do
            it "is" do
              order = FactoryGirl.create(:order)
              order.payment_method= 'card'
              order.status= st
              order.save(validate: false)
              expect(order).to be_paid
            end
          end
        end
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

  describe '.can_create?' do
    context 'when 0 to 69 orders' do
      before { Order.delete_all }
      before { 69.times { FactoryGirl.create(:order, payment_method: 'cash') } }
      it 'is true' do
        expect(Order.can_create?).to be_truthy
      end
    end
    context 'when 70+ orders' do
      before { Order.delete_all }
      before { 71.times { FactoryGirl.create(:order, payment_method: 'cash') } }
      it 'is falsy' do
        expect(Order.can_create?).to be_falsy
      end
    end
  end
end
