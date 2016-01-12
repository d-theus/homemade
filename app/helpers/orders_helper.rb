module OrdersHelper
  def payment_methods
    Order::PAYMENT_METHODS.map do |pm|
      [
        I18n.t("activerecord.values.order.payment_method.#{pm}"),
        pm
      ]
    end
  end
end
