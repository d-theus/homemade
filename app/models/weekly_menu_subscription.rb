class WeeklyMenuSubscription < ActiveRecord::Base
  validates :email,
    presence: true,
    format: { with: Devise::email_regexp },
    uniqueness: true

  before_create :generate_token

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(128)
  end
end
