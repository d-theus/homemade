require 'rails_helper'

RSpec.describe "yandex_kassa/response", type: :view do
  before { assign(:invoiceId, '202202202') }
  before { assign(:code, '0') }
  let(:xml) { Nokogiri::XML(response.body) }

  shared_examples 'node_with_attributes' do |name, attrs|
    attrs = attrs.with_indifferent_access

    it "has node with name '#{name}' with attributes: #{attrs.inspect}" do
      selector = %Q(#{name}#{attrs.map {|k,v| "[#{k}='#{v}']"}.join('')})
      expect(xml.css(selector).size).not_to be_zero
    end
  end

  describe 'checkOrder' do
    before { render template: 'yandex_kassa/checkOrder' }

    it_behaves_like 'node_with_attributes',
      'checkOrderResponse',
      { code: 0, invoiceId: '202202202', shopId: Rails.configuration.yandex_kassa.shop_id }
  end

  describe 'cancelOrder' do
    before { render template: 'yandex_kassa/cancelOrder' }

    it_behaves_like 'node_with_attributes',
      'cancelOrderResponse',
      { code: 0, invoiceId: '202202202', shopId: Rails.configuration.yandex_kassa.shop_id }
  end

  describe 'paymentAviso' do
    before { render template: 'yandex_kassa/paymentAviso' }

    it_behaves_like 'node_with_attributes',
      'paymentAvisoResponse',
      { code: 0, invoiceId: '202202202', shopId: Rails.configuration.yandex_kassa.shop_id }
  end
end

