class WeekRecipesController < ApplicationController
  def index
    @recipes = WeekRecipes.includes(:recipe)
    render json: @recipes
  end

  def update
  end
end
