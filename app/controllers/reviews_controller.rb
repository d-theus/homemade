class ReviewsController < ApplicationController
  def show
    @vk_board = Vk::ReviewsBoard.new
  end
end
