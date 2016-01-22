class Customer < ActiveRecord::Base
  has_many :orders, dependent: :destroy
  accepts_nested_attributes_for :orders

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :address, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone,
    presence: true,
    length: { minimum: 11, maximum: 11 },
    uniqueness: true,
    format: /\d{11}/
end
