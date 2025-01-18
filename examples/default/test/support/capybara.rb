# frozen_string_literal: true

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  require "capybara"
  require "capybara/rails"

  Capybara.configure do |config|
    config.default_max_wait_time = 2
    config.save_path = "tmp/screenshots"
    config.enable_aria_label = true
    config.server = :puma, {Silent: true}
    config.test_id = "data-testid"
  end
end
