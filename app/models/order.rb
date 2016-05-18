class Order < ActiveRecord::Base
  STATUS_TABLE = {
    :nil => [ :new ],
    :new => [ :cancelled ],
    :pending => [ :paid, :cancelled ],
    :paid => [ :awaiting_delivery, :awaiting_refund ],
    :awaiting_refund => [ :cancelled ],
    :awaiting_delivery => [ :closed ],
    :cancelled => [],
    :closed => []
  }.with_indifferent_access

  PAYMENT_METHODS = %w(cash card)

  PRICES = {
    3 => {
      2 => 2500,
      3 => 3500,
      4 => 4500
    },
    5 => {
      2 => 3500,
      3 => 4500,
      4 => 6300
    }
  }
  DISCOUNT = nil

  validates :payment_method, presence: true, format: /\A(card|cash)\z/
  validates :count, presence: true, inclusion: { in: [3,5] }
  validates :servings, presence: true, inclusion: { in: [2,3,4] }
  validates :name,  presence: true, length: { minimum: 2, maximum: 99 }
  validates :phone,  presence: true, format: /\A7\d{10}\z/
  validates :address, presence: true, length: { minimum: 2, maximum: 250 }
  validate  :check_status
  validate  :check_interval
  before_destroy :can_destroy?
  after_create   :make_card_pending
  before_create   :make_discount

  def pay
    change_status(:paid)
  end

  def cancel
    change_status(:cancelled)
  end

  def close
    change_status(:closed)
  end

  def can_pay?
    can_change_status_to?(:paid)
  end

  def can_cancel?
    can_change_status_to? :cancelled
  end

  def can_close?
    can_change_status_to? :closed
  end

  def can_change_status_to?(new_status)
    old_status = (id && self.class.find(id).status) || :nil
    return false if old_status.to_s == new_status.to_s
    STATUS_TABLE[old_status].include?(new_status.to_sym)
  end

  def can_destroy?
    %w(cancelled closed).include? status
  end

  def paid?
    return false if self.payment_method != 'card'
    %w(paid awaiting_delivery awaiting_refund closed).include? status
  end

  STATUS_TABLE.keys.each do |key|
    next if key == 'paid'
    define_method "#{key}?" do
      status == key
    end
  end

  def price
    if DISCOUNT && self.discount?
      Order.price_for(self) * (1.0 - DISCOUNT)
    else
      Order.price_for(self)
    end
  end

  def make_awaiting_delivery
    if  (self.payment_method == 'card' && self.status == 'paid') ||
        (self.payment_method == 'cash' && self.status == 'new')
      self.status = 'awaiting_delivery'
      self.save(validate: false)
    else
      false
    end
  end


  private

  def change_status(new_status)
    new_status = new_status.try(:to_sym) || :nil

    if can_change_status_to? new_status
      self.status = new_status.to_s
      self.save
    else
      self.errors[:status] =
        "Невозможно изменить статус заказа на #{new_status}"
      return false
    end
  end

  def check_status
    if can_change_status_to? status
      true
    else
      self.errors[:status] =
        "Невозможно изменить статус заказа на #{status}"
      return false
    end
  end

  def check_interval
    if interval.blank?
      self.errors[:interval] = I18n.t "errors.messages.blank"
      return false
    end
    ms = /(?<b>\d+)-(?<e>\d+)/.match interval
    unless ms && ms[:e] && ms[:b]
      self.errors[:interval] = I18n.t "errors.messages.invalid"
      return false
    end
    b = ms[:b].to_i
    e = ms[:e].to_i
    unless e > b
      self.errors[:interval] = "время начала интервала больше времени конца"
      return false
    end
    true
  end

  def make_card_pending
    if self.payment_method == 'card'
      self.status = 'pending'
      self.save(validate: false)
    else
      true
    end
  end

  def make_discount
    self.discount = Order.discount?
    true
  end

  class << self
    def can_create?
      #Order.where('status in (?)', [:new, :pending, :paid]).count < 70
      false
    end

    def discount?
      DISCOUNT && Order.where('status in (?)', [:new, :paid]).count < 10
    end

    def advance
      Order.where(status: ['new','paid']).find_each { |o| o.make_awaiting_delivery }
      Order.where(status: 'pending').find_each { |o| o.cancel } 
    end

    def close
      Order.where(status: 'awaiting_delivery').find_each { |o| o.close }
    end

    def price_for(arg)
      order = if arg.is_a? Hash
                OpenStruct.new(arg)
              elsif arg.is_a? Order
                arg
              end

      prices_for_count = PRICES.fetch(order.count) { fail 'Invalid count'}
      price = prices_for_count.fetch(order.servings) { fail 'Invalid servings' }
      price
    end
  end
end
