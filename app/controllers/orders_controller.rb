class OrdersController < ApplicationController
  before_action :authenticate_or_forbid, except: [:new, :create, :pay, :received]
  before_action :fetch_order, only: [:cancel, :close, :pay, :destroy]

  def new
    @customer = Customer.new
    @order = @customer.orders.build
  end

  def create
    @order = Order.new(order_params.except(:customer))
    @customer = Customer.find_by_phone(order_params.require(:customer)[:phone]) || Customer.new(order_params[:customer])
    if @customer.persisted? && @customer.name != order_params.require(:customer)[:name]
      @customer.name = nil
      @customer.address = nil
      flash.now[:alert] = 'Найден такой телефон, но пара "телефон - имя" не совпадает. '
      render :new, status: :unprocessable_entity
      return
    end
    if @customer.persisted? && @customer.name == order_params.require(:customer)[:name] && order_params.require(:customer)[:address]
      @customer.address = order_params.require(:customer)[:address]
    end

    Order.transaction do
      @customer.save!
      @order.customer_id = @customer.id
      @order.save!
    end

    if admin_signed_in?
      redirect_to orders_path
    else
      redirect_to received_order_path
    end

  rescue
    if @customer.errors.any?
      flash.now[:alert] = 'Не удалось создать запись о клиенте. '
    elsif @order.errors.any?
      flash.now[:alert] = "Заказ не создан. #{@order.errors.full_messages}"
    end
    render :new, status: :unprocessable_entity
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
    if @order.pay
      flash.now[:notice] = "Заказ №#{@order.id} завершен"
      redirect_to orders_path
    else
      flash.now[:alert] = "Нельзя заплатить за заказ №#{@order.id}"
      redirect_to orders_path, status: :unprocessable_entity
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
      :payment_method, :interval,
      :state, :count, :by_phone,
      customer: [ :name, :phone, :address ]
    )
  end

  #def customer_params
    #params.require(:order).fetch(:customer, {}).permit(
      #:name, :phone, :address
      #)
  #end

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
