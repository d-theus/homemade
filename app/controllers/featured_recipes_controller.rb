class FeaturedRecipesController < ApplicationController
  respond_to :json

  def index
    render json: Recipe.featured
  end
end
