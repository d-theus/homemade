require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_view/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Homemade
  class Application < Rails::Application
    # config.time_zone = 'Central Time (US & Canada)'
    config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.default_locale = :ru
    config.active_record.default_timezone = :local

    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.woff *.ttf *.svg *.eot)
    config.assets.paths << "#{Rails}/vendor/assets/fonts"
    config.assets.paths << "#{Rails}/vendor/assets/twitter/bootstrap/fonts"

    config.filter_parameters += [:password, :data]
  end
end
