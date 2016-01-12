class Customer < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :address, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone,
    presence: true,
    length: { minimum: 2, maximum: 100 },
    uniqueness: true,
    format: /\+\d{11}/
end
