require 'rails_helper'

RSpec.describe "orders/index.html.haml", type: :view do
  before(:all) { 100.times { FactoryGirl.create :order } }
  let!(:orders) { Order.order('created_at DESC') }
  let!(:order) { orders.first }
  before(:each) { allow_any_instance_of(ApplicationHelper)
                  .to receive(:admin?).and_return(true) }
  before { assign :orders, Order.order('created_at DESC').paginate(per_page: 15, page: params[:page])}
  before { render template: 'orders/index', layout: 'layouts/application' }

  subject { rendered }

  it { is_expected.to have_css '.pagination' }
  it { is_expected.to have_css %(a[href="/order/#{order.id}/cancel"]#{order.can_cancel? ? nil : '[disabled]'}) }
  it { is_expected.to have_css %(a[href="/order/#{order.id}/close"]#{order.can_close?  ? nil : '[disabled]'}) }
end
