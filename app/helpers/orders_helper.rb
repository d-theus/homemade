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
    [*8..20].map { |st| ["#{st}:00 ― #{st+3}:00", "#{st}-#{st+3}"] }
  end
end
