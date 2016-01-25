class RecipesController < ApplicationController
  respond_to :json
  before_action :authenticate_or_forbid, except: [:show]
  before_action :fetch_recipe, only: [:show, :edit, :update, :destroy]

  def new
    @recipe = Recipe.new
  end

  def edit
  end

  def create
    @recipe = Recipe.new(recipe_params.except(:inventory_item_ids))
    success = nil
    begin
      Recipe.transaction do
        @recipe.save!
        @recipe.update!(inventory_item_ids: recipe_params[:inventory_item_ids])
        success = true
      end
      redirect_to recipe_path(@recipe)
    rescue
      success = false
    end


    unless success
      flash.now[:alert] = t 'flash.create.alert'
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @recipe.update(recipe_params)
      respond_to do |f|
        f.html do
          flash.now[:notice] = t 'flash.update.notice'
          redirect_to recipe_path(@recipe)
        end
        f.json do
          render nothing: true, status: :ok
        end
      end
    else
      respond_to do |f|
        f.html do
          flash.now[:alert] = t 'flash.update.alert'
          render :edit, status: :unprocessable_entity
        end
        f.json do
          render json: { message: @recipe.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  end

  def show
  end

  def index
    @recipes = Recipe.order('day ASC').paginate(page: params[:page], per_page: 15)
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
      :title, :subtitle, :day,
      :calories, :cooking_time,
      :photo, :picture,
      inventory_item_ids: []
    )
  end

  def fetch_recipe
    @recipe = Recipe.find(params[:id])
  end
end
