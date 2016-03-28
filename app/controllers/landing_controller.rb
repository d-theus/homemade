class LandingController < ApplicationController
  def index
    @recipes = Recipe.featured.order('DAY ASC').includes(:inventory_items)
    @subscription = WeeklyMenuSubscription.new
    @order = Order.new
    if cookies[:last_order]
      order = Order.find(cookies[:last_order])
      if order.try(:can_pay?)
        @unpaid_order = order
      end
    end
  end
end
