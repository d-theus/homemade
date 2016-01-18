require 'rails_helper'

RSpec.describe OrdersController, type: :controller do
  before(:all) { Customer.delete_all }
  before(:all) { FactoryGirl.create(:customer) }

  describe '#index' do
    context 'when not signed in' do
      before { sign_in nil }
      before { get :index }
      it_behaves_like 'an unauthorized request'
    end

    context 'when signed in' do
      before { sign_in }
      before { get :index }

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
    context 'with new invalid customer' do
      let(:attrs) { FactoryGirl.attributes_for(:order_with_customer).merge({customer: { phone: ''}}) }
      let(:req) { post :create, order: attrs }

      it 'fails to create order' do
        expect { req() }.not_to change(Order, :count)
      end
      it 'fails to create customer' do
        expect { req() }.not_to change(Customer, :count)
      end
      it 'has errors in customer' do
        req()
        expect(assigns[:customer].errors).not_to be_empty
      end
      it_behaves_like 'unprocessable entity request'
    end
    context 'with valid order' do
      before { post :create, order: FactoryGirl.attributes_for(:order_with_customer) }

      it_behaves_like 'an authorized request'

      it 'has empty alert' do
        expect(flash.now[:alert]).to be_nil
      end

      it 'redirects to "Order Received" page' do
        expect(response).to redirect_to(received_order_path)
      end
    end

    context 'with invalid order' do
      before { post :create, order: FactoryGirl.attributes_for(:order_with_customer, count: 2) }

      it_behaves_like 'unprocessable entity request'
    end
  end

  describe 'update methods' do
    let(:order) { FactoryGirl.create(:order) }

    describe '#close' do
      let(:req) { post :close, id: order.id }
      context 'when not signed in' do
        before { sign_in nil }
        it_behaves_like 'an unauthorized request'
      end

      context 'when signed in' do
        before { sign_in }

        context 'new order with cash' do
          before { order.update status: 'new', payment_method: 'cash' } 
          it_behaves_like 'successful request'
        end
        context 'pending order with card' do
          before { order.update status: 'pending', payment_method: 'card' } 
          it_behaves_like 'unprocessable entity request'
        end
        context 'paid order' do
          before { order.update status: 'paid' } 
          it_behaves_like 'successful request'
        end
        context 'closed order' do
          before { order.update status: 'closed' } 
          it_behaves_like 'unprocessable entity request'
        end
        context 'cancelled order' do
          before { order.update status: 'cancelled' } 
          it_behaves_like 'unprocessable entity request'
        end

      end
    end
    describe '#cancel' do
      let(:req) { post :cancel, id: order.id }
      context 'when not signed in' do
        before { sign_in nil }
        it_behaves_like 'an unauthorized request'
      end

      context 'when signed in' do
        before { sign_in }

        context 'new order' do
          before { order.update status: 'new' } 
          it_behaves_like 'successful request'
        end

        context 'pending order' do
          before { order.update status: 'paid' } 
          it_behaves_like 'successful request'
        end

        context 'paid order' do
          before { order.update status: 'paid' } 
          it_behaves_like 'successful request'
        end

        context 'closed order' do
          before { order.update status: 'closed' } 
          it_behaves_like 'unprocessable entity request'
        end

        context 'canceled order' do
          before { order.update status: 'cancelled' } 
          it_behaves_like 'unprocessable entity request'
        end
      end
    end
    describe '#pay' do
      let(:req) { post :pay, id: order.id }
      context 'when not signed in' do
        before { sign_in nil }
        it_behaves_like 'an authorized request'

        context 'new order' do
          before { order.update status: 'new' } 
          it_behaves_like 'unprocessable entity request'
        end

        context 'pending order' do
          before { order.update status: 'pending' } 
          it_behaves_like 'successful request'
        end

        context 'paid order' do
          before { order.update status: 'paid' } 
          it_behaves_like 'unprocessable entity request'
        end

        context 'closed order' do
          before { order.update status: 'closed' } 
          it_behaves_like 'unprocessable entity request'
        end

        context 'canceled order' do
          before { order.update status: 'cancelled' } 
          it_behaves_like 'unprocessable entity request'
        end
      end
    end
  end

  describe '#delete' do
    let(:order) { FactoryGirl.create(:order) }
    context 'when not signed in' do
      before { sign_in nil }
      before { delete :destroy, id: order.id }
      it_behaves_like 'an unauthorized request'
    end

    context 'when authorized' do
      before { sign_in }

      it_behaves_like 'an authorized request'

      context 'attempting to delete' do
        context 'paid order' do
          before { order.update(status: 'paid')}
          before { delete :destroy, id: order.id }
          it_behaves_like 'unprocessable entity request'
        end
        context 'new order' do
          before { delete :destroy, id: order.id }
          it_behaves_like 'unprocessable entity request'
        end
      end
    end
  end

  describe '#received' do
    it 'fetches order'
    it 'fetched order.customer'
    it 'concerned with access rights'
  end
end
