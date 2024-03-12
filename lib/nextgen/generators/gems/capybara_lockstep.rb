install_gem "capybara-lockstep", group: :test
inject_into_file "app/views/layouts/application.html.erb",
  "\n    <%= capybara_lockstep if defined?(Capybara::Lockstep) %>",
  after: /<head\b.*$/
