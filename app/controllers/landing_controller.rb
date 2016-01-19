class LandingController < ApplicationController
  def index
    @recipes = Recipe.featured.includes(:inventory_items)
    @subscription = WeeklyMenuSubscription.new
    @order = Order.new
  end
end
