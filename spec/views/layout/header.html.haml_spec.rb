require 'rails_helper'

RSpec.describe "shared/_header", type: :view do
  subject { rendered }

  context 'not authorized' do
    before { allow_any_instance_of(ApplicationHelper).to receive(:admin?).and_return(false) }
    before { render}

    it { is_expected.not_to have_link 'Выйти', href: '/admin/sign_out' }
    it { is_expected.to have_css '[href^="tel:"]' }
  end

  context 'authorized' do
    before { allow_any_instance_of(ApplicationHelper).to receive(:admin?).and_return(true) }
    before { render}

    it { is_expected.to have_link 'Выйти', href: destroy_admin_session_path }
    it { is_expected.not_to have_css '[href^="tel:"]' }

    it { is_expected.to have_css %Q(.dropdown-toggle[name="recipes"]) }
    it { is_expected.to have_css %Q(li a[href="#{recipes_path}"]) }
    it { is_expected.to have_css %Q(li a[href="#{new_recipe_path}"]) }
  end
end
