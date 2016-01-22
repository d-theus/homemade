class LandingController < ApplicationController
  def index
    @recipes = Recipe.featured.includes(:inventory_items)
    @subscription = WeeklyMenuSubscription.new
    @order = Order.new
    @customer = @order.build_customer
  end
end
