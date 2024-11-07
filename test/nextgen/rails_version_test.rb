# frozen_string_literal: true

require "test_helper"

module Nextgen
  class RailsVersionTest < Minitest::Test
    def test_current_version_is_loaded_from_rails_versions_yaml
      current = RailsVersion.current

      assert_empty current.args
      assert_equal Rails.version, current.label
      assert_instance_of Hash, current.asset_pipelines
      assert_instance_of Hash, current.databases
      assert_instance_of Hash, current.default_features
      assert_equal({devcontainer: "devcontainer files"}, current.optional_features)
    end

    def test_edge_version_is_same_as_current_except_label_and_args
      current = RailsVersion.current
      edge = RailsVersion.edge

      assert_equal "edge (8-0-stable)", edge.label
      assert_equal ["--edge"], edge.args

      %i[asset_pipelines databases default_features optional_features].each do |attr|
        assert_equal current.public_send(attr), edge.public_send(attr)
      end
    end

    def test_main_version_parses_version_number_from_rails_github_repo
      stub_request(:get, "https://raw.githubusercontent.com/rails/rails/main/RAILS_VERSION").to_return(body: <<~RUBY)
        8.0.0.rc1
      RUBY

      main = RailsVersion.main
      assert_equal "main (8.0.0.rc1)", main.label
    end
  end
end
