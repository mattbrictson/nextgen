# frozen_string_literal: true

say_git "Install factory_bot_rails"
install_gem "factory_bot_rails", group: %i[development test]

say_git "Include factory_bot methods in tests"
copy_test_support_file "factory_bot.rb"

say_git "Replace fixtures with factories in generators"
if minitest?
  inject_into_file "config/initializers/generators.rb", <<~RUBY, after: "Rails.application.config.generators do |g|\n"
    g.test_framework :test_unit, fixture: false, fixture_replacement: :factory_bot
  RUBY
end
inject_into_file "config/initializers/generators.rb", <<~RUBY, after: "Rails.application.config.generators do |g|\n"
  # Generate "users_factory.rb" instead of "users.rb"
  g.factory_bot suffix: "factory"
RUBY
