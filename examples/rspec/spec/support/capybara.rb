require "capybara/rails"
require "capybara/rspec"

Capybara.configure do |config|
  config.default_max_wait_time = 2
  config.disable_animation = true
  config.enable_aria_label = true
  config.server = :puma, {Silent: true}
  config.test_id = "data-testid"
end
