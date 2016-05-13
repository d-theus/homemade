class Contact < ActiveRecord::Base
  validates :topic,
    length: { maximum: 255 }

  validates :text,
    presence: true,
    length: { minimum: 5, maximum: 2000 }

  validates :email,
    presence: true,
    format: { with: Devise::email_regexp }

  validates :name, length: { maximum: 99 }

  before_create :make_topic

  def read
    self.unread = false
    self.save
  end

  def unread?
    self.unread
  end

  private

  def make_topic
    self.topic = "без темы" if self.topic.blank?
  end
end
