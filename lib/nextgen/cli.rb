require "thor"

module Nextgen
  class CLI < Thor
    extend ThorExt::Start

    map %w[-v --version] => "version"

    desc "version", "Display nextgen version", hide: true
    def version
      say "nextgen/#{VERSION} #{RUBY_DESCRIPTION}"
    end
  end
end
