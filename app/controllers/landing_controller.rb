class LandingController < ApplicationController
  def index
    @recipes = Recipe.featured.order('DAY ASC').includes(:inventory_items)
    @subscription = WeeklyMenuSubscription.new
    @order = Order.new
  end
end
