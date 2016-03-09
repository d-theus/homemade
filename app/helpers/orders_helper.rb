module OrdersHelper
  def statuses
    Order::STATUS_TABLE
    .keys
    .select { |k| k.to_s != 'nil' }
    .map { |st| [ I18n.t("activerecord.values.order.status.#{st}"), st ] }
    .unshift(['любой', nil])
  end

  def payment_methods
    Order::PAYMENT_METHODS
    .map { |pm| [ I18n.t("activerecord.values.order.payment_method.#{pm}"), pm ] }
  end

  def intervals
    [
      ["10:00 ― 13:00", "10-13"],
      ["13:00 ― 18:00", "13-18"],
      ["18:00 ― 21:00", "18-21"],
      ["10:00 ― 21:00", "10-21"]
    ]
  end
end
