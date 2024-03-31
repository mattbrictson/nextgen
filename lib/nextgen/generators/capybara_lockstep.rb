install_gem "capybara-lockstep", group: :test, require: false

inject_into_file "app/views/layouts/application.html.erb",
  "\n    <%= capybara_lockstep if defined?(Capybara::Lockstep) %>",
  after: /<head\b.*$/

capybara_path = rspec? ? "spec/support/capybara.rb" : "test/support/capybara.rb"
inject_into_file capybara_path,
  "\n  require \"capybara-lockstep\"",
  after: /require "capybara".*$/
