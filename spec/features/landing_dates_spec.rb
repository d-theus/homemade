require 'rails_helper'

RSpec.feature "LandingDates", type: :feature do
  subject { page }

  context 'when it\'s Monday to Saturday' do
    before {  Date.stub(:today) do Date.new 2016, 01, 04 end }
    before { visit '/' }
    describe 'delivery date' do
      it { is_expected.to have_css '#d_date', text: I18n.l((Date.new 2016, 1, 10), format: '%e %B') }
    end
    describe 'next week begin' do
      it { is_expected.to have_css '#bow', text: I18n.l((Date.new 2016, 1, 11), format: '%e %B') }
    end
    describe 'next week end' do
      it { is_expected.to have_css '#eow', text: I18n.l((Date.new 2016, 1, 15), format: '%e %B') }
    end
  end

  context 'when it\'s Sunday' do
    before {  Date.stub(:today) do Date.new 2016, 01, 10 end }
    before { visit '/' }
    describe 'delivery date' do
      it { is_expected.to have_css '#d_date', text: I18n.l((Date.new 2016, 1, 17), format: '%e %B') }
    end
    describe 'next week begin' do
      it { is_expected.to have_css '#bow', text: I18n.l((Date.new 2016, 1, 18), format: '%e %B') }
    end
    describe 'next week end' do
      it { is_expected.to have_css '#eow', text: I18n.l((Date.new 2016, 1, 22), format: '%e %B') }
    end
  end

end
