class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      redirect_to received_order
    else
      flash.now[:alert] = 'Заказ не создан'
      render :new
    end
  end

  def index
  end

  private

  def order_params
    params.require(:order).permit(
      { customer: [ :name, :phone, :address ] },
      :payment_method,
      :state
    )
  end
end
