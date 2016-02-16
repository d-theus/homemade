class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create, :pay, :received]
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
        redirect_to received_order_path
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

  def pay
    @order = Order.find(params[:customerNumber])
    if params[:action] == 'paymentAviso'
      if @order.pay
        flash.now[:notice] = "Заказ №#{@order.id} завершен"
        redirect_to orders_path
      else
        flash.now[:alert] = "Нельзя заплатить за заказ №#{@order.id}"
        redirect_to orders_path, status: :unprocessable_entity
      end
    else
      render json: { code: }
    end
  end

  def index
    @orders = Order
    .order('created_at DESC')
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
end
