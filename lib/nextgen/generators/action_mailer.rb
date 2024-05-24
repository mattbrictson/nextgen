# frozen_string_literal: true

say_git "Configure Action Mailer for testing"
copy_test_support_file "mailer.rb"
if minitest?
  empty_directory_with_keep_file "test/mailers"
elsif rspec?
  empty_directory_with_keep_file "spec/mailers"
end

say_git "Ensure absolute URLs can be used in all environments"
insert_into_file "config/environments/development.rb", <<-RUBY, after: "raise_delivery_errors = false\n"
  config.action_mailer.default_url_options = {host: "localhost:3000"}
  config.action_mailer.asset_host = "http://localhost:3000"
RUBY

insert_into_file "config/environments/test.rb", <<-RUBY, after: "config.action_mailer.delivery_method = :test\n"
  config.action_mailer.default_url_options = {host: "localhost:3000"}
  config.action_mailer.asset_host = "http://localhost:3000"
RUBY

insert_into_file "config/environments/production.rb", <<-RUBY, after: /config\.action_mailer\.raise_deliv.*\n/
  config.action_mailer.default_url_options = {
    host: ENV.fetch("RAILS_HOSTNAME", "app.example.com"),
    protocol: "https"
  }
  config.action_mailer.asset_host = "https://\#{ENV.fetch("RAILS_HOSTNAME", "app.example.com")}"
RUBY
