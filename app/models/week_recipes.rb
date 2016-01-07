class WeekRecipes < ActiveRecord::Base
  belongs_to :recipe
  after_create :normalize
  after_destroy :normalize

  def normalize
    while self.class.count > 5
      self.class.first.delete()
    end
    while self.class.count < 5
      self.class.create()
    end
  end

  class << self
    def setup
      for day in 1..5
        self.create(day: day)
      end
    end
  end
end
