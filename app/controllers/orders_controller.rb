class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create, :pay, :received, :failed]
  before_action :fetch_order, only: [:cancel, :close, :destroy]

  def new
    @order = Order.new
  end

  def create
    @order = Order.new(order_params)
    if @order.save
      if admin_signed_in?
        redirect_to orders_path
      else
        cookies[:last_order] = { value: @order.id, expires: next_friday } if @order.can_pay?
        redirect_to received_orders_path(id: @order.id)
      end
    else
      flash.now[:alert] = t "flash.create.alert"
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    if @order.cancel
      flash.now[:notice] = "Заказ №#{@order.id} отменен"
      redirect_to orders_path
    else
      flash.now[:alert] = "Нельзя отменить заказ №#{@order.id}"
      redirect_to orders_path, status: :unprocessable_entity
    end
  end

  def close
    if @order.close
      flash.now[:notice] = "Заказ №#{@order.id} завершен"
      redirect_to orders_path
    else
      flash.now[:alert] = "Нельзя завершить заказ №#{@order.id}"
      redirect_to orders_path, status: :unprocessable_entity
    end
  end

  def index
    @orders = Order
    .order(order_by)
    .where(query)
    respond_to do |f|
      f.html do
        @orders = @orders.paginate(page: params[:page], per_page: 12)
      end
      f.xls
    end
  end

  def destroy
    if @order.destroy
      flash.now[:notice] = "Успешно удалили заказ №#{@order.id}"
      redirect_to orders_path
    else
      flash.now[:alert] = "Нельзя удалить заказ #{@order.id}: неподходящий статус"
      render :index, status: :unprocessable_entity
    end
  end

  def received
    @subscription = WeeklyMenuSubscription.new
    if params[:id] || params[:customerNumber]
      @order = Order.find(params[:id] || params[:customerNumber])
    end
  end

  def failed
    @order = Order.find(params[:customerNumber])
  end

  private

  def order_state
    params.require(:order).permit(
      :state
    )
  end

  def order_params
    params.require(:order).permit(
    :count,
    :payment_method,
    :status,
    :name,
    :phone,
    :address,
    :interval,
    :by_phone
    )
  end

  def order_id
    params.require(:id)
  end

  def fetch_order
    @order = Order.find(order_id)
  end

  def query_params
    params.permit(:payment_method, :status)
  end

  def query
    query_params.keep_if { |k,v| !v.blank? }
  end

  def order_by
    params.permit(:order_by)
  end

  def next_friday
    Time.zone.now + (1 + (4 - Time.zone.now.wday) % 7).days
  end
end
