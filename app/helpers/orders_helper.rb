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
    price_method = Order.discount? ? :discount_price_for : :original_price_for
    Order::PRICES.map do |count, prices_for_servings|
      prices_for_servings.each do |servings, _|
        ["#{count} ужинов за #{send(price_method, count: count, servings: servings)} р.", "#{count} на #{servings}"]
      end
    end
  end

  def options_for_count
    [
      ["5 ужинов", 5],
      ["3 ужинa", 3]
    ]
  end

  def options_for_servings
    [
      ["На 2-x человек", 2],
      ["На 3-x человек", 3],
      ["На 4-x человек", 4]
    ]
  end

  def discount_price_for(hash)
    (Order.price_for(hash) * (1.0 - Order::DISCOUNT)).floor
  end

  def original_price_for(hash)
    Order.price_for(hash)
  end

  def discount?
    @order_discount ||= Order.discount? 
  end

  def discount
    "#{(Order::DISCOUNT * 100).to_i}%" if Order::DISCOUNT
  end
end
