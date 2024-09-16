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

      assert_equal "edge (7-2-stable)", edge.label
      assert_equal ["--edge"], edge.args

      %i[asset_pipelines databases default_features optional_features].each do |attr|
        assert_equal current.public_send(attr), edge.public_send(attr)
      end
    end
  end
end
