# frozen_string_literal: true

install_gems "capybara", "selenium-webdriver", group: :test
copy_test_support_file "capybara.rb.tt"
copy_test_support_file "system.rb"

copy_file "lib/templates/rspec/system/system_spec.rb"
prevent_autoload_lib "templates"
