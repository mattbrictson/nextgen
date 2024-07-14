# frozen_string_literal: true

require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium,
    using: (ENV["SHOW_BROWSER"] ? :chrome : :headless_chrome),
    screen_size: [1400, 1400] do |options|
      # Allows running in Docker
      options.add_argument("--disable-dev-shm-usage")
      options.add_argument("--no-sandbox")
    end
end
