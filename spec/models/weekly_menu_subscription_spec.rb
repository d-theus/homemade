require 'rails_helper'

RSpec.describe WeeklyMenuSubscription, type: :model do
  let!(:c) { WeeklyMenuSubscription }
  describe 'validates' do
    it '.email' do
      expect(c.new(email: nil)).not_to be_valid
      expect(c.new(email: 'asfd')).not_to be_valid
      expect(c.new(email: 'asflj@lksjdf')).not_to be_valid
      expect(c.new(email: 'asfdsdf@aslkdfj.ru')).to be_valid
    end
  end

  describe 'token' do
    let(:wms) { c.create(email: 'subscriber@example.com') }

    it 'has token' do
      expect(wms.token).to be_a String
    end
  end
end
