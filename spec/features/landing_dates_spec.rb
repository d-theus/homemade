require 'rails_helper'
require 'landing_helper'
include LandingHelper

RSpec.feature "LandingDates", type: :feature do
  subject { page }

  [*4..7].each do |day|
    context "when it's #{Date.new(2016,1,day).strftime('%A')}" do
      before(:each) { Timecop.travel(Date.new 2016, 1, day)}
      before(:each) { visit '/' }
      after (:each) { Timecop.return }

      describe 'delivery date' do
        it { is_expected.to have_css '#d_date',
             text: date_format(Date.new 2016, 1, 10) }
      end
      describe 'next week begin' do
        it { is_expected.to have_css '#bow',
             text: date_format(Date.new 2016, 1, 11) }
      end
      describe 'next week end' do
        it { is_expected.to have_css '#eow',
             text: date_format(Date.new 2016, 1, 15) }
      end
    end
  end

  [*8..10].each do |day|
    context "when it's #{Date.new(2016,01,day).strftime('%A')}" do
      before(:each) { Timecop.travel(Date.new 2016, 1, day)}
      before(:each) { visit '/' }
      after (:each) { Timecop.return }

      describe 'delivery date' do
        it { is_expected.to have_css '#d_date',
             text: date_format(Date.new 2016, 1, 17) }
      end
      describe 'next week begin' do
        it { is_expected.to have_css '#bow',
             text: date_format(Date.new 2016, 1, 18) }
      end
      describe 'next week end' do
        it { is_expected.to have_css '#eow',
             text: date_format(Date.new 2016, 1, 22) }
      end
    end
  end

end
