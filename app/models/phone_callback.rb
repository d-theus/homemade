class PhoneCallback < ActiveRecord::Base
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :phone,
    presence: true,
    length: { minimum: 11, maximum: 11 },
    uniqueness: true,
    format: /\d{11}/

  def close
    self.pending = false
    self.save
  end

  def pending?
    self.pending
  end
end
