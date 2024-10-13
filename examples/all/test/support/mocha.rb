# frozen_string_literal: true

require "mocha/minitest"

# Reference: https://rubydoc.info/gems/mocha/Mocha/Configuration
Mocha.configure do |config|
  config.strict_keyword_argument_matching = true
  config.stubbing_method_on_nil = :prevent
  config.stubbing_non_existent_method = :prevent
end
