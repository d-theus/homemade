class InventoryItemsController < ApplicationController
  respond_to :json
  before_action :authenticate_or_forbid, except: [:show]

  def index
    render json: InventoryItem.all
  end

  def create
    @ii = InventoryItem.create(ii_params)
    if @ii.persisted?
      render json: { inventory_item: @ii, status: :success }
    else
      render json: { errors: @ii.errors }, status: :unprocessable_entity
    end
  end

  def update
    @ii = InventoryItem.find(params[:id])
    if @ii.update(ii_params)
      render json: { inventory_item: @ii, status: :success }
    else
      render json: { errors: @ii.errors },
        status: :unprocessable_entity
    end
  end

  def destroy
    @ii = InventoryItem.find(params[:id])
    if @ii.destroy
      render json: { status: :success}
    else
      render json: { errors: @ii.errors },
        status: :bad_request
    end
  end

  def show
    @ii = InventoryItem.find(params[:id])
    render json: { inventory_item: @ii, status: :success }
  end

  private

  def ii_params
    params.require(:inventory_item).permit(:name, :image)
  end
end
