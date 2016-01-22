class FeaturedRecipesController < ApplicationController
  before_action :authenticate_or_forbid, except: [:index]
  respond_to :json

  def index
    render json: Recipe.featured
  end

  def destroy
    if Recipe.where.not(day: nil).update_all(day: nil)
      render nothing: true, status: :ok
    else
      render json: { message: 'Рецепты не были обновлены'}, status: :unprocessable_entity
    end
  end
end
