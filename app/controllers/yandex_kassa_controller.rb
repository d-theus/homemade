class YandexKassaController < ApplicationController
  respond_to :xml
  before_action :digest, except: :pay
  before_action :fetch_order

  def paymentAviso
    if @order.paid?
      render xml: xml_response(
        code: YandexKassa::CODE_SUCCESS,
        message: 'Оплата уже была совершена успешно'
      ), status: :ok
      return
    end

    unless @order.can_pay?
      render xml: xml_response(
        code: YandexKassa::CODE_UNPROCESSABLE,
        message: 'Этот заказа нельзя оплатить'
      ), status: :unprocessable_entity
      return
    end

    if (@order.price.to_f - params[:shopSumAmount].to_f).abs > @order.price * 0.05
      render xml: xml_response(
        code: YandexKassa::CODE_UNPROCESSABLE,
        message: 'Сумма оплаты сильно отличается от требуемой'
      ), status: :unprocessable_entity
      return
    end
    
    if @order.pay
      render xml: xml_response(
        code: YandexKassa::CODE_SUCCESS,
        message: 'Оплата прошла успешно'
      ), status: :ok
    else
      render xml: xml_response(
        code: YandexKassa::CODE_UNPROCESSABLE,
        message: 'Оплата не прошла'
      ), status: :unprocessable_entity
    end
  end

  def checkOrder
    if @order.paid?
      render xml: xml_response(
        code: YandexKassa::CODE_DENY,
        message: 'Оплата уже была совершена успешно'
      ), status: :unprocessable_entity
      return
    end

    unless @order.can_pay?
      render xml: xml_response(
        code: YandexKassa::CODE_DENY,
        message: 'Этот заказа нельзя оплатить'
      ), status: :unprocessable_entity
      return
    end

    if (@order.price.to_f - params[:shopSumAmount].to_f).abs > @order.price * 0.05
      render xml: xml_response(
        code: YandexKassa::CODE_DENY,
        message: 'Сумма оплаты сильно отличается от требуемой'
      ), status: :unprocessable_entity
      return
    end

    render xml: xml_response(
      code: YandexKassa::CODE_SUCCESS,
      message: 'Готовы принять перевод'
    ), status: :ok
  end

  def cancelOrder
    unless @order.can_cancel?
      render xml: xml_response(
        code: YandexKassa::CODE_UNPROCESSABLE,
        message: 'Заказ не отменён: не соответствует статус'
      ), status: :unprocessable_entity
    end

    if @order.cancel
      render xml: xml_response(
        code: YandexKassa::CODE_SUCCESS,
        message: 'Заказ отменён'
      ), status: :ok
    end
  end

  def pay
    unless @order.can_pay?
      render text: 'За этот заказ нельзя заплатить',
        status: :unprocessable_entity
      return false
    end

    redirect_to Rails.application.config.yandex_kassa.url, method: :post
  end

  private
  
  def xml_response(hash)
    fail 'Expicit code required' unless hash[:code]
    fail 'Expicit message required' unless hash[:message]
    hash.merge({
      performedDatetime: Time.now,
      shopId: Rails.configuration.yandex_kassa.shop_id, 
      invoiceId: params[:invoiceId],
      orderSumAmount: @order && @order.price
    })
  end

  def digest
    unless Rails.configuration.yandex_kassa.hash(params) == params[:md5]
      render xml: xml_response(
        code: YandexKassa::CODE_UNAUTHORIZED,
        message: 'Похоже, запрос подделан'
      ), status: :unauthorized
      return false
    end
  end

  def fetch_order
    begin
      id = params[:customerNumber] || params[:order_id]
      @order = Order.find(id)
    rescue ActiveRecord::RecordNotFound
      render xml: xml_response(
        code: YandexKassa::CODE_UNPROCESSABLE,
        message: 'Нет такого заказа'
      ), status: :not_found
      return false
    end
  end
end
