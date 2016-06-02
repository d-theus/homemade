module Vk
  class ReviewsBoard < Board
    BOARD_ID = 33518459
    attr_accessor :comments

    def initialize
      super(BOARD_ID)
    end
  end
end

