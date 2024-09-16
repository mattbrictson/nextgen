# frozen_string_literal: true

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
  end
end
