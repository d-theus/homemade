require 'rails_helper'

RSpec.describe WeeklyMenuSubscriptionsController, type: :controller do
  describe 'unsubscribe' do
    let(:wms) { WeeklyMenuSubscription.create(email: 'subscriber@example.com')}

    context 'without token' do
      let(:req) { delete :destroy, id: wms.id }
      it_behaves_like '401_response'
    end

    context 'with invalid token' do
      let(:req) { delete :destroy, id: wms.id, token: 'invalid' }
      it_behaves_like '401_response'
    end

    context 'with valid token' do
      let(:req) { delete :destroy, id: wms.id, token: wms.token }
      before { wms.inspect }

      it_behaves_like 'successful request'

      it 'reduces subscriptions count' do
        expect { req() }.to change(WeeklyMenuSubscription, :count).by(-1)
      end
    end
  end
end
