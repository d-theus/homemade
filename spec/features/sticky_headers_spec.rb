require 'rails_helper'

RSpec.feature "Sticky Header", type: :feature do
  before { || visit '/'}
  it 'is present' do
    expect(page).to have_css 'header'
  end

  context 'top' do
    it 'is invisible' do
      expect(page).not_to have_css 'header.sticky.in'
    end
  end

  context 'scrolled down', js: true do
    it 'is visible' do
      page.execute_script 'window.scrollTo(0, 40);'
      expect(page).to have_css 'header.sticky.in'
    end

    context 'then refreshed' do
      it 'is visible' do
        page.execute_script 'window.scrollTo(0, 40);'
        visit current_path
        #page.execute_script 'window.location.reload();'
        expect(page).to have_css 'header.sticky.in'
      end
    end
  end

end
