class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create, :pay, :received]
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
    @order = Order.new(order_params)

    Order.transaction do
      @customer.save!
      @order.customer_id = @customer.id
      @order.save!
    end

  redirect_to received_order_path

  rescue 
    if @customer.errors.any?
      flash.now[:alert] = 'Не удалось создать запись о клиенте'
    end

    unless @order.persisted?
      flash.now[:alert] = 'Заказ не создан'
    end
    render :new, status: :unprocessable_entity
    return
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
    @orders = Order
    .order('created_at DESC')
    .where(query_params)
    .paginate(page: params[:page], per_page: 12)
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
      :interval,
      :state, :count
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

  def query_params
    params.permit(:payment_method, :status)
  end
end
