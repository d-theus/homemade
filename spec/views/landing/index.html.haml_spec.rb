require 'rails_helper'

RSpec.describe "landing/index.html.haml", type: :view do
  before :each do render end
  it 'has title' do
    expect(rendered).to have_selector 'title'
  end
  it 'has meta-description' do
    expect(rendered).to have_selector 'meta[name="description"]'
  end
  it 'has meta-keywords' do
    expect(rendered).to have_selector 'meta[name="keywords"]'
  end

  it 'has offer link' do
    expect(rendered).to have_selector "a[href=#{offer_path}]"
  end
  it 'has policy link' do
    expect(rendered).to have_selector "a[href=#{policy_path}]"
  end
end
