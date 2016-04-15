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

  def prices
    if Order.discount?
    [
      ["5 ужинов за #{discount_price_for(5)} р.", 5],
      ["3 ужина за #{discount_price_for(3)} р.", 3]
    ]
    else
    [
      ["5 ужинов за #{price_for(5)} р.", 5],
      ["3 ужина за #{price_for(3)} р.", 3]
    ]
    end
  end

  def discount_price_for(count)
    (Order::PRICES[count] * (1.0 - Order::DISCOUNT)).floor
  end

  def original_price_for(count)
    Order::PRICES[count]
  end

  def discount?
    @order_discount ||= Order.discount? 
  end
end
