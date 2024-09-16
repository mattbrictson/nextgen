# frozen_string_literal: true

require "open-uri"
require "rails/version"
require "yaml"

module Nextgen
  RailsVersion = Struct.new(
    :args,
    :label,
    :asset_pipelines,
    :databases,
    :default_features,
    :optional_features,
    keyword_init: true
  )

  class << RailsVersion
    def current
      from_yaml(:current) do |version|
        version.label.sub!("%%CURRENT_VERSION%%") { ::Rails.version }
      end
    end

    def edge
      from_yaml(:edge)
    end

    def main
      from_yaml(:main) do |version|
        version.label.sub!("%%MAIN_VERSION%%") { main_version }
      end
    end

    private

    def from_yaml(key)
      @yaml ||= begin
        yaml_path = File.expand_path("../../config/rails_versions.yml", __dir__)
        YAML.load_file(yaml_path, aliases: true, symbolize_names: true)
      end
      new(**@yaml.fetch(key)).tap do |version|
        yield(version) if block_given?
      end.freeze
    end

    def main_version
      @main_version ||= begin
        version_rb = URI.open("https://raw.githubusercontent.com/rails/rails/main/version.rb").read
        version_pattern = /\s+MAJOR\s+= (\d+)\n\s*MINOR\s+= (\d+)\n\s*TINY\s+= (\d+)\n\s*PRE\s+= "(\w+)"/
        version_rb.match(version_pattern)&.captures&.join(".")
      rescue OpenURI::HTTPError
        "unknown"
      end
    end
  end
end
