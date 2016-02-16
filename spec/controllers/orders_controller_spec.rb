require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  describe '#index' do
    before { sign_in as_user }
    before { get :index }

    context 'when not signed in' do
      let(:as_user) { nil }

      it_behaves_like 'an unauthorized request'
    end

    context 'when signed in' do
      let(:as_user) { double('admin') }

      it_behaves_like 'an authorized request'
      it 'assigns @orders' do
        expect(assigns :orders).not_to be_nil
      end
    end
  end

  describe '#new' do
    before { get :new }

    it_behaves_like 'an authorized request'
    it 'assigns @order' do
      expect(assigns :order).not_to be_nil
    end
  end

  describe '#create' do
    context 'w/ invalid' do
      before { post :create, order: FactoryGirl.attributes_for(:order, attrs) }

      context 'count' do
       let(:attrs) {{ count: 2 }}
       it_behaves_like 'unprocessable entity request'
      end
      context 'payment method' do
        let(:attrs) {{ payment_method: :lol  }}
        it_behaves_like 'unprocessable entity request'
      end
      context 'interval' do
        let(:attrs) {{ interval: 2  }}
        it_behaves_like 'unprocessable entity request'
      end
      context 'name' do
        let(:attrs) {{ name: nil  }}
        it_behaves_like 'unprocessable entity request'
      end
      context 'phone' do
        let(:attrs) {{ phone: 2  }}
        it_behaves_like 'unprocessable entity request'
      end
      context 'address' do
        let(:attrs) {{ address: 2  }}
        it_behaves_like 'unprocessable entity request'
      end
    end

    context 'w/ valid' do
      before { sign_in as_user }
       before { post :create, order: FactoryGirl.attributes_for(:order) }
       subject { response }

       context 'when admin' do
         let(:as_user) { double('admin') }

         it { is_expected.to redirect_to orders_path }
       end

       context 'when customer' do
         let(:as_user) { nil }

         it { is_expected.to redirect_to received_order_path }
       end
    end
  end

  describe 'update methods' do
    let!(:order) { FactoryGirl.create(:order) }

    describe '#close' do
      let(:req) { post :close, id: order.id }
      context 'when not signed in' do
        before { sign_in nil }
        it_behaves_like 'an unauthorized request'
      end
    end

    describe '#cancel' do
      let(:req) { post :cancel, id: order.id }
      context 'when not signed in' do
        before { sign_in nil }
        it_behaves_like 'an unauthorized request'
      end
    end
  end

  describe '#delete' do
    let!(:order) { FactoryGirl.create(:order) }
    before { sign_in as_user }

    context 'when not signed in' do
      let(:as_user) { nil }
      before { delete :destroy, id: order.id }
      it_behaves_like 'an unauthorized request'
    end

    context 'when authorized' do
      let(:as_user) { double('admin') }
      let(:status) { 'new' }
      before { order.status = status; order.save(validate: false ) }
      before { delete :destroy, id: order.id }
      subject { response }

      it_behaves_like 'an authorized request'

      context 'attempt to delete' do
        context 'paid order' do
          let(:status) { 'paid '}
          it_behaves_like 'unprocessable entity request'
        end
        context 'new order' do
          let(:status) { 'new'}
          it_behaves_like 'unprocessable entity request'
        end
        context 'pending order' do
          let(:status) { 'pending'}
          it_behaves_like 'unprocessable entity request'
        end
        context 'cancelled order' do
          let(:status) { 'cancelled'}
          it_behaves_like 'successful request'
          it { is_expected.to redirect_to orders_path }
        end
      end
    end
  end

  describe '#received' do
    before { get :received }

    it_behaves_like 'an authorized request'

    it 'has @subscription' do
      expect(assigns :subscription).not_to be_nil
    end
  end
end
