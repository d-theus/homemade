require 'rails_helper'

RSpec.describe Vk::Board, type: :model do
  describe 'It gets arbitrary board' do
    it 'passed BOARD_ID = <reviews board id> it yields valid board' do
      expect(Vk::Board.new(Vk::ReviewsBoard::BOARD_ID)).to be_a Vk::Board
    end
  end
end

RSpec.describe Vk::ReviewsBoard, type: :model do
  describe 'It gets reviews board' do
    it 'yields valid board with no ID passed' do
      expect(Vk::ReviewsBoard.new).to be_a Vk::Board
    end
    it 'has array of comments assigned' do
      expect(Vk::ReviewsBoard.new.comments).to be_an Array
    end
  end
end
