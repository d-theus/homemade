class YandexKassaController < ApplicationController
  respond_to :xml
  skip_before_action :verify_authenticity_token
  before_action :digest, except: :pay
  before_action :fetch_order
  before_action :fill_params

  def paymentAviso
    if @order.paid?
      @code = YandexKassa::CODE_SUCCESS
      render  status: :ok
      return
    end

    unless @order.can_pay?
      @code = YandexKassa::CODE_UNPROCESSABLE
      @message = 'Этот заказа нельзя оплатить'
      render  status: :unprocessable_entity
      return
    end

    if (@order.price.to_f - params[:shopSumAmount].to_f).abs > @order.price * 0.05
      @code = YandexKassa::CODE_UNPROCESSABLE
      @message = 'Сумма оплаты сильно отличается от требуемой'
      render  status: :unprocessable_entity
      return
    end
    
    if @order.pay
      @code = YandexKassa::CODE_SUCCESS
      render  status: :ok
    else
      @code = YandexKassa::CODE_UNPROCESSABLE
      @message = 'Оплата не прошла'
      render  status: :unprocessable_entity
    end
  end

  def checkOrder
    if @order.paid?
      @code = YandexKassa::CODE_DENY
      @message = 'Оплата уже была совершена успешно'
      render  status: :unprocessable_entity
      return
    end

    unless @order.can_pay?
      @code = YandexKassa::CODE_DENY
      @message = 'Этот заказа нельзя оплатить'
      render  status: :unprocessable_entity
      return
    end

    if (@order.price.to_f - params[:shopSumAmount].to_f).abs > @order.price * 0.05
      @code = YandexKassa::CODE_DENY
      @message = 'Сумма оплаты сильно отличается от требуемой'
      render  status: :unprocessable_entity
      return
    end

    @code = YandexKassa::CODE_SUCCESS
    render  status: :ok
  end

  def cancelOrder
    unless @order.can_cancel?
      @code = YandexKassa::CODE_UNPROCESSABLE,
      @message = 'Заказ не отменён: не соответствует статус'
      render  status: :unprocessable_entity
    end

    if @order.cancel
      @code = YandexKassa::CODE_SUCCESS
      render  status: :ok
    end
  end

  private

  def digest
    unless Rails.configuration.yandex_kassa.hash(params) == params[:md5]
      @code = YandexKassa::CODE_UNAUTHORIZED
      @message = 'Похоже, запрос подделан'
      render  status: :unauthorized
      return false
    end
  end

  def fetch_order
    begin
      id = params[:customerNumber] || params[:order_id]
      @order = Order.find(id)
    rescue ActiveRecord::RecordNotFound
      @code = YandexKassa::CODE_UNPROCESSABLE
      @message = 'Нет такого заказа'
      render  status: :not_found
      return false
    end
  end

  def fill_params
    @invoiceId = params[:invoiceId]
  end
end
