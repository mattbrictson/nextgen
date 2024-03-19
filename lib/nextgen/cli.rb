require "thor"

module Nextgen
  class CLI < Thor
    extend ThorExtensions

    map %w[-v --version] => "version"

    option :style, type: :string, default: nil
    desc "create APP_PATH", "Generate a Rails app interactively in APP_PATH"
    def create(app_path)
      Commands::Create.run(app_path, options)
    end

    desc "version", "Display nextgen version", hide: true
    def version
      say "nextgen/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
