class LandingController < ApplicationController
  before_action :handle_unpaid_order, only: [:index]
  def index
    @recipes = Recipe.featured.order('DAY ASC').includes(:inventory_items)
    @subscription = WeeklyMenuSubscription.new
    @order = Order.new
  end

  private

  def handle_unpaid_order
    if cookies[:last_order]
      order = Order.find(cookies[:last_order])
      if order.try(:can_pay?)
        @unpaid_order = order
      else
        cookies.delete(:last_order)
      end
    end
  end
end
