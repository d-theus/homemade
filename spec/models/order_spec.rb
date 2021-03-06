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

    describe '.servings' do
      it 'fails with no servings' do
        expect(FactoryGirl.build(:order, servings: nil)).not_to be_valid
      end

      it 'accepts servings of [2,3,4]' do
        expect(FactoryGirl.build(:order, servings: 2)).to be_valid
        expect(FactoryGirl.build(:order, servings: 3)).to be_valid
        expect(FactoryGirl.build(:order, servings: 4)).to be_valid

        expect(FactoryGirl.build(:order, servings: 0)).not_to be_valid
        expect(FactoryGirl.build(:order, servings: 1)).not_to be_valid
        expect(FactoryGirl.build(:order, servings: 5)).not_to be_valid
        expect(FactoryGirl.build(:order, servings: -1)).not_to be_valid
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

  describe 'discounting' do
    context 'when 0 to 10 orders' do
      before { Order.delete_all }
      before { 3.times { FactoryGirl.create(:order, payment_method: 'cash') } }
      describe '.discount?' do

        it 'is truthy' do
          expect(Order.discount?).to be_falsy
        end
      end

      describe 'order price' do
        let (:ord_cash) { o = FactoryGirl.create(:order, payment_method: 'cash', count: 5, servings: 2); o.reload; o }
        let (:ord_card) { o = FactoryGirl.create(:order, payment_method: 'card', count: 3, servings: 2); o.reload; o }

        it 'has price decreased' do
          expect(Order.count).to be < 10
          expect(ord_cash.price).to be == Order::price_for(count: 5, servings: 2)
          expect(ord_card.price).to be == Order::price_for(count: 3, servings: 2)
        end
      end

      describe '#discount?' do
        it 'is' do
          ord = FactoryGirl.create(:order, payment_method: 'cash', count: 5)
          expect(ord).not_to be_discount
        end
      end
    end

    context 'when > 10 orders' do
      before { Order.delete_all }
      before { 10.times { FactoryGirl.create(:order, payment_method: 'cash') } }
      describe '.discount?' do

        it 'is falsy' do
          expect(Order.discount?).to be_falsy
        end
      end
      describe 'order price' do
        ord_cash = FactoryGirl.create(:order, payment_method: 'cash', count: 5, servings: 2)
        ord_cash.reload
        ord_card = FactoryGirl.create(:order, payment_method: 'card', count: 3, servings: 4)
        ord_card.reload

        it 'has ordinary price' do
          expect(ord_cash.price).to be == Order::price_for(count: 5, servings: 2)
          expect(ord_card.price).to be == Order::price_for(count: 3, servings: 4)
        end
      end
      describe '#discount?' do
        it 'isnt' do
          ord = FactoryGirl.create(:order, payment_method: 'cash', count: 5)
          expect(ord).not_to be_discount
        end
      end
    end
  end

  describe '.advance' do
    before { Order.delete_all }
    before { 20.times { FactoryGirl.create(:order, payment_method: 'cash')} }
    before { 20.times { FactoryGirl.create(:order, payment_method: 'card')} }
    before { Order.where(status: 'pending', payment_method: 'card').limit(10).each { |r| r.status= 'paid'; r.save(validate: false) } }

    it 'makes only paid+card or new+cash orders awaiting_delivery' do
      expect { Order.advance }.to change { Order.where(status: 'awaiting_delivery').count }
      .from(0)
      .to(30)
      expect { Order.advance }.not_to change { Order.where(status: 'pending').count }
      expect { Order.advance }.not_to change { Order.where(status: 'cancelled').count }
      expect { Order.advance }.not_to change { Order.where(status: 'awaiting_refund').count }
      expect { Order.advance }.not_to change { Order.where(status: 'closed').count }
    end
  end

  describe '.close' do
    before { Order.delete_all }
    before { 20.times { FactoryGirl.create(:order, payment_method: 'cash')} }
    before { 20.times { FactoryGirl.create(:order, payment_method: 'card')} }
    before { Order.where(status: 'new', payment_method: 'cash').each { |r| r.status= 'awaiting_delivery'; r.save(validate: false) } }
    before { Order.where(status: 'pending', payment_method: 'card').limit(10).each { |r| r.status= 'awaiting_delivery'; r.save(validate: false) } }

    it 'closes orders with awaiting_delivery' do
      expect { Order.close }.to change { Order.where(status: 'awaiting_delivery').count }
      .from(30)
      .to(0)
    end
  end

  describe '.price_for' do
    it 'takes valid hash and returns price correctly' do
      expect(Order.price_for(count: 3, servings: 2)).to eq 2500
      expect(Order.price_for(count: 3, servings: 3)).to eq 3500
      expect(Order.price_for(count: 3, servings: 4)).to eq 4500
      expect(Order.price_for(count: 5, servings: 2)).to eq 3500
      expect(Order.price_for(count: 5, servings: 3)).to eq 4500
      expect(Order.price_for(count: 5, servings: 4)).to eq 6300
    end
    it 'takes invalid hash and fails' do
      expect { Order.price_for(count: nil, servings: nil)}.to raise_error RuntimeError
      expect { Order.price_for(count: 3, servings: nil)}.to   raise_error 'Invalid servings'
      expect { Order.price_for(count: nil, servings: 3)}.to   raise_error 'Invalid count'
      expect { Order.price_for(count: 21, servings: 3)}.to    raise_error 'Invalid count'
      expect { Order.price_for(count: 3, servings: 30)}.to    raise_error 'Invalid servings'
    end
    it 'takes valid order and returns price correctly' do
      expect(Order.price_for FactoryGirl.build(:order, count: 3, servings: 2)).to eq 2500
      expect(Order.price_for FactoryGirl.build(:order, count: 3, servings: 3)).to eq 3500
      expect(Order.price_for FactoryGirl.build(:order, count: 3, servings: 4)).to eq 4500
      expect(Order.price_for FactoryGirl.build(:order, count: 5, servings: 2)).to eq 3500
      expect(Order.price_for FactoryGirl.build(:order, count: 5, servings: 3)).to eq 4500
      expect(Order.price_for FactoryGirl.build(:order, count: 5, servings: 4)).to eq 6300
    end
    it 'takes invalid order and fails' do
      expect { Order.price_for FactoryGirl.build(:order, count: nil, servings: nil) }.to raise_error RuntimeError
      expect { Order.price_for FactoryGirl.build(:order, count: nil, servings: 2) }.to raise_error 'Invalid count'
      expect { Order.price_for FactoryGirl.build(:order, count: 3, servings: nil) }.to raise_error 'Invalid servings'
    end
  end
end
