# frozen_string_literal: true

say_git "Install launchy"
install_gem "launchy", group: %i[development test]

say_git "Configure puma to open browser on startup"
copy_file "lib/puma/plugin/open.rb"
append_to_file "config/puma.rb", <<~RUBY

  # Automatically open the browser when in development
  require_relative "../lib/puma/plugin/open"
  plugin :open
RUBY
prevent_autoload_lib "puma/plugin"
