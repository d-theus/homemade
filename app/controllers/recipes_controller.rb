class RecipesController < ApplicationController
  respond_to :json
  before_action :authenticate_or_forbid, except: [:show]
  before_action :fetch_recipe, only: [:show, :edit, :update, :destroy]

  def new
  end

  def edit
  end

  def create
    @recipe = Recipe.new(recipe_params)
    if @recipe.save
      render json: @recipe
    else
      render json: { errors: @recipe.errors },
        status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      render json: @recipe
    else
      render json: { errors: @recipe.errors },
        status: :unprocessable_entity
    end
  end

  def show
    render json: @recipe
  end

  def index
    @recipes = Recipe.paginate(page: params[:page], per_page: 25)
  end

  def destroy
    if @recipe.destroy
      render nothing: true
    else
      render json: { errors: @recipe.errors },
        status: :unprocessable_entity
    end
  end

  private

  def recipe_params
    params.require(:recipe).permit(
      :title, :subtitle,
      :calories, :cooking_time,
      inventory_items: []
    )
  end

  def fetch_recipe
    @recipe = Recipe.find(params[:id])
  end
end
