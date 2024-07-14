# frozen_string_literal: true

Rails.application.config.generators do |g|
  # Generate "users_factory.rb" instead of "users.rb"
  g.factory_bot suffix: "factory"
  g.test_framework :test_unit, fixture: false, fixture_replacement: :factory_bot
  # Disable generators we don't need.
  g.javascripts false
  g.stylesheets false
end
