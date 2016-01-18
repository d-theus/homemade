module OrdersHelper
  def statuses
    Order::STATUS_TABLE.keys.map do |st|
      [
        I18n.t("activerecord.values.order.status.#{st}"),
        st
      ]
    end
  end

  def payment_methods
    Order::PAYMENT_METHODS.map do |pm|
      [
        I18n.t("activerecord.values.order.payment_method.#{pm}"),
        pm
      ]
    end
  end
end
