class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create, :pay]
  before_action :fetch_order, only: [:cancel, :close, :pay, :destroy]

  def new
    @order = Order.new
  end

  def create
    @customer = if customer_id
                  Customer.find(customer_id)
                else
                  Customer.new(customer_params)
                end

    unless @customer.save
      flash.now[:alert] = 'Не удалось создать запись о клиенте'
      render :new, status: :unprocessable_entity
      return
    end

    @order = Order.new(order_params)
    if @order.save
      cookies[:last_order_id] = @order.id
      redirect_to received_order_path
    else
      flash.now[:alert] = 'Заказ не создан'
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    if @order.cancel
      flash.now[:notice] = "Заказ №#{@order.id} отменен"
      render :index, status: :ok
    else
      flash.now[:alert] = "Нельзя отменить заказ №#{@order.id}"
      render :index, status: :unprocessable_entity
    end
  end

  def close
    if @order.close
      flash.now[:notice] = "Заказ №#{@order.id} завершен"
      render :index, status: :ok
    else
      flash.now[:alert] = "Нельзя завершить заказ №#{@order.id}"
      render :index, status: :unprocessable_entity
    end
  end

  def pay
    if @order.pay
      flash.now[:notice] = "Заказ №#{@order.id} завершен"
      render :index, status: :ok
    else
      flash.now[:alert] = "Нельзя заплатить за заказ №#{@order.id}"
      render :index, status: :unprocessable_entity
    end
  end

  def index
    @orders = Order.order('created_at DESC').paginate(page: params[:page], per_page: 12)
  end

  def destroy
    if @order.destroy
      flash.now[:notice] = "Успешно удалили заказ №#{@order.id}"
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
      :payment_method,
      :state
    )
  end

  def customer_params
    params.require(:order).fetch(:customer, {}).permit(
      :name, :phone, :address
      )
  end

  def customer_id
    params.fetch(:order, {})
    .fetch(:customer, {})
    .fetch(:id, nil)
  end

  def order_id
    params.require(:id)
  end

  def fetch_order
    @order = Order.find(order_id)
  end
end
