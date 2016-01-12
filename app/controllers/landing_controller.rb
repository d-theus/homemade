class LandingController < ApplicationController
  def index
    @recipes = Recipe.featured.includes(:inventory_items)
  end
end
