require 'rails_helper'

RSpec.describe YandexKassaController, type: :controller do
  let(:yparams) {{
    requestDatetime: Time.new(2016, 02, 02, 12, 15).iso8601,
    shopId: Rails.configuration.yandex_kassa.shop_id,
    shopArticleId: '456',
    invoiceId: '1234567',
    orderCreatedDatetime: Time.new(2016, 02, 02, 12, 15),
    customerNumber: '3294469',
    orderSumAmount: '1500.00',
    orderSumCurrencyPaycash: 643,
    orderSumBankPaycash: 1001,
    shopSumAmount: '1498.26',
    shopSumCurrencyPaycash: 643,
    shopSumBankPaycash: 1001,
    paymentDatetime: Time.new(2016, 02, 02, 12, 15, 15).iso8601,
    paymentPayerCode: 42007148320,
    paymentType: 'AC',
    cps_user_country_code: 'RU',
    format: 'application/xml'
  }}

  let(:new_order) { o = FactoryGirl.create(:order, count: 5, payment_method: 'card'); o.reload; o }
  let(:cancelled_order) { o = new_order; o.status = 'cancelled'; o.save(validate: false); o.reload; o }
  let(:paid_order) { o = new_order; o.status = 'paid'; o.save(validate: false); o.reload; o }
  let(:unpaid_order) { o = new_order; o.payment_method = 'cash'; o.status = 'new'; o.save(validate: false); o.reload; o }
  let(:pending_order) { o = new_order; o.status = 'pending'; o.save(validate: false); o.reload; o }

  def valid_payment_params(hash = {})
    hash[:action] ||= 'paymentAviso'
    order = hash[:order] ||= pending_order
    hash[:customerNumber] ||= order.id
    hash[:shopSumAmount] ||= '3490.00'
    vp = yparams.merge(hash)
    vp[:md5] = Rails.configuration.yandex_kassa.hash(vp)
    vp
  end

  def valid_check_params(hash = {})
    hash[:action] ||= 'checkOrder'
    order = hash[:order] ||= pending_order
    hash[:customerNumber] ||= order.id
    hash[:shopSumAmount] ||= '3490.00'
    vp = yparams.merge(hash)
    vp[:md5] = Rails.configuration.yandex_kassa.hash(vp)
    vp
  end

  def valid_cancel_params(hash = {})
    hash[:action] ||= 'cancelOrder'
    order = hash[:order] ||= pending_order
    hash[:customerNumber] ||= order.id
    hash[:shopSumAmount] ||= '3490.00'
    vp = yparams.merge(hash)
    vp[:md5] = Rails.configuration.yandex_kassa.hash(vp)
    vp
  end

  shared_examples 'xml_response_with_code' do |code|
    it 'has mime type xml' do
      expect(response.content_type).to eq 'application/xml'
    end
    it "#{code}" do
      hash = Hash.from_xml(response.body)["hash"].with_indifferent_access
      expect(hash[:code].to_s).to eq code.to_s
    end
  end

  shared_examples 'http_response_with_status' do |status|
    it "#{status}" do
      expect(response).to have_http_status(status)
    end
  end

  shared_examples 'no_success_requrest' do
    it 'does not change order' do
      order = Order.find(payment_params[:customerNumber])
      expect(order).not_to be_paid
    end
  end

  describe 'POST paymentAviso' do
    before { post :paymentAviso, payment_params }

    context 'with invalid customer id' do
      let(:payment_params) { valid_payment_params(customerNumber: -5 ) }

      it_behaves_like 'xml_response_with_code', 200
      it_behaves_like 'http_response_with_status', :not_found
    end

    context 'with invalid md5' do
      let(:payment_params) { valid_payment_params.merge(md5: 'lkajlsdfj') }

      it_behaves_like 'xml_response_with_code', 1
      it_behaves_like 'http_response_with_status', :unauthorized

      it_behaves_like 'no_success_requrest'
    end

    context 'with invalid amount' do
      context 'when too much' do
        let(:payment_params) { valid_payment_params(shopSumAmount: '5000')}

        it_behaves_like 'xml_response_with_code', 200
        it_behaves_like 'http_response_with_status', :unprocessable_entity
        it_behaves_like 'no_success_requrest'
      end
      context 'when too small' do
        let(:payment_params) { valid_payment_params(shopSumAmount: '1500')}

        it_behaves_like 'xml_response_with_code', 200
        it_behaves_like 'http_response_with_status', :unprocessable_entity
        it_behaves_like 'no_success_requrest'
      end
    end

    context 'when order cannot be paid' do
      context 'when cash' do
        let(:payment_params) { valid_payment_params(order: unpaid_order) }

        it_behaves_like 'xml_response_with_code', 200
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
      context 'when cancelled' do
        let(:payment_params) { valid_payment_params(order: cancelled_order) }

        it_behaves_like 'xml_response_with_code', 200
        it_behaves_like 'http_response_with_status', :unprocessable_entity
        it_behaves_like 'no_success_requrest'
      end
    end

    context 'when all params are good' do
      let(:payment_params) { valid_payment_params }

      it_behaves_like 'xml_response_with_code', 0
      it_behaves_like 'http_response_with_status', :ok

      it 'changes order status to "paid"' do
        order = Order.find(payment_params[:customerNumber])
        expect(order).to be_paid
      end
    end

    context 'when doubles' do
      let(:payment_params) { valid_payment_params }

      before { post :paymentAviso, payment_params }

      it_behaves_like 'xml_response_with_code', 0
      it_behaves_like 'http_response_with_status', :ok
    end
  end

  describe 'POST checkOrder' do
    before { post :checkOrder, check_params }

    context 'with invalid customer id' do
      let(:check_params) { valid_check_params(customerNumber: -5 ) }

      it_behaves_like 'xml_response_with_code', 200
      it_behaves_like 'http_response_with_status', :not_found
    end

    context 'with invalid md5' do
      let(:check_params) { valid_payment_params.merge(md5: 'lkajlsdfj') }

      it_behaves_like 'xml_response_with_code', 1
      it_behaves_like 'http_response_with_status', :unauthorized
    end

    context 'with invalid amount' do
      context 'when too much' do
        let(:check_params) { valid_check_params(shopSumAmount: '5000')}

        it_behaves_like 'xml_response_with_code', 100
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
      context 'when too small' do
        let(:check_params) { valid_check_params(shopSumAmount: '1500')}

        it_behaves_like 'xml_response_with_code', 100
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
    end

    context 'when order cannot be paid' do
      context 'when cash' do
        let(:check_params) { valid_check_params(order: unpaid_order) }

        it_behaves_like 'xml_response_with_code', 100
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
      context 'when cancelled' do
        let(:check_params) { valid_check_params(order: cancelled_order) }

        it_behaves_like 'xml_response_with_code', 100
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
      context 'when paid' do
        let(:check_params) { valid_check_params(order: paid_order) }

        it_behaves_like 'xml_response_with_code', 100
        it_behaves_like 'http_response_with_status', :unprocessable_entity
      end
    end

    context 'when all params are good' do
      let(:check_params) { valid_check_params }

      it_behaves_like 'xml_response_with_code', 0
      it_behaves_like 'http_response_with_status', :ok
    end
  end

  describe 'POST cancelOrder' do
    before { post :cancelOrder, cancel_params }

    context 'with invalid customer id' do
      let(:cancel_params) { valid_cancel_params(customerNumber: -5) }

       it_behaves_like 'xml_response_with_code', 200
       it_behaves_like 'http_response_with_status', :not_found
    end
    context 'with invalid md5' do
       let(:cancel_params) { valid_cancel_params.merge(md5: 'asldfjlsakdf') }

       it_behaves_like 'xml_response_with_code', 1
       it_behaves_like 'http_response_with_status', :unauthorized
    end
    context 'when order cannot be cancelled' do
       let(:cancel_params) { valid_cancel_params(order: cancelled_order) }

       it_behaves_like 'xml_response_with_code', 200
       it_behaves_like 'http_response_with_status', :unprocessable_entity
    end

    context 'when all good' do
       let(:cancel_params) { valid_cancel_params }

       it_behaves_like 'xml_response_with_code', 0
       it_behaves_like 'http_response_with_status', :ok
    end
  end

end
