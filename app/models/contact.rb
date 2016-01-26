class Contact < ActiveRecord::Base
  validates :topic,
    presence: true,
    length: { minimum: 1, maximum: 255 }

  validates :text,
    presence: true,
    length: { minimum: 5, maximum: 2000 }

  validates :email,
    presence: true,
    format: { with: Devise::email_regexp }

  def read
    self.unread = false
    self.save
  end

  def unread?
    self.unread
  end
end
