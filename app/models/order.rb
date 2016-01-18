class Order < ActiveRecord::Base
  belongs_to :customer

  STATUS_TABLE = {
    :nil => [ :new ],
    :new => [ :pending, :cancelled, :awaiting_delivery],
    :pending => [ :paid, :cancelled ],
    :paid => [ :awaiting_delivery, :awaiting_refund ],
    :awaiting_refund => [ :cancelled ],
    :awaiting_delivery => [ :closed ],
    :cancelled => [],
    :closed => []
  }.with_indifferent_access

  PAYMENT_METHODS = %w(cash card)

  validates :customer_id, presence: true
  validates :customer, presence: true
  validates :payment_method, presence: true
  validates :count, presence: true, inclusion: { in: [3,5] }
  validate  :check_status
  before_destroy :can_destroy?
  after_create   :make_card_pending

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
    return true if old_status.to_s == new_status.to_s
    STATUS_TABLE[old_status].include?(new_status.to_sym)
  end

  def can_destroy?
    %w(cancelled closed).include? status
  end

  STATUS_TABLE.keys.each do |key|
    define_method "#{key}?" do
      status == key
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

  def make_card_pending
    if self.payment_method == 'card'
      self.status = 'pending'
    end
    true
  end
end
