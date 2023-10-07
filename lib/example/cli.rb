require "thor"

module Example
  class CLI < Thor
    extend ThorExt::Start

    map %w[-v --version] => "version"

    desc "version", "Display example version", hide: true
    def version
      say "example/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
