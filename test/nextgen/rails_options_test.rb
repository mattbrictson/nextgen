# frozen_string_literal: true

require "test_helper"

class Nextgen::RailsOptionsTest < Minitest::Test
  def test_api_mode_can_be_specified
    opts = build_rails_options
    opts.api!

    assert(opts.api?)
    assert_equal(["--api"], opts.to_args)
  end

  def test_api_mode_prohibits_frontend_options
    opts = build_rails_options
    opts.api!

    assert_prohibited { opts.css = "sass" }
    assert_prohibited { opts.javascript = "esbuild" }
  end

  def test_css_prohibits_api_mode
    opts = build_rails_options
    opts.css = "sass"

    assert_prohibited { opts.api! }
  end

  def test_javascript_prohibits_api_mode
    opts = build_rails_options
    opts.javascript = "esbuild"

    assert_prohibited { opts.api! }
  end

  def test_node_requirement_depends_on_css_option
    %w[bootstrap bulma postcss sass].each do |css|
      opts = build_rails_options
      opts.css = css

      assert(opts.requires_node?)
    end

    opts = build_rails_options
    opts.css = "tailwind"

    refute(opts.requires_node?)
  end

  def test_node_requirement_depends_on_javascript_option
    %w[webpack esbuild rollup].each do |js|
      opts = build_rails_options
      opts.javascript = js

      assert(opts.requires_node?)
    end

    opts = build_rails_options
    opts.javascript = "importmap"

    refute(opts.requires_node?)
  end

  def test_css_can_be_specified
    opts = build_rails_options
    opts.css = "bulma"

    assert_equal(["--css=bulma"], opts.to_args)
  end

  def test_javascript_can_be_specified
    opts = build_rails_options
    opts.javascript = "esbuild"

    assert_equal(["--javascript=esbuild"], opts.to_args)
  end

  def test_javascript_can_be_skipped_by_assigning_nil
    opts = build_rails_options
    opts.javascript = nil

    assert(opts.skip_javascript?)
    assert_equal(["--skip-javascript"], opts.to_args)
  end

  def test_asset_pipeline_can_be_specified
    opts = build_rails_options

    opts.asset_pipeline = :propshaft
    assert_equal(["--asset-pipeline=propshaft"], opts.to_args)
  end

  def test_invalid_asset_pipeline_raises
    opts = build_rails_options

    assert_raises(ArgumentError) { opts.asset_pipeline = :something }
  end

  def test_assigning_nil_disables_asset_pipeline_allows_and_prohibits_other_frontend_options
    opts = build_rails_options
    opts.asset_pipeline = nil

    assert_prohibited { opts.css = "sass" }
    assert_prohibited { opts.javascript = "rollup" }
  end

  def test_vite_disables_asset_pipeline_and_uses_esbuild_under_the_hood
    opts = build_rails_options

    refute_predicate opts, :vite?

    opts.vite!
    assert_predicate opts, :vite?
    assert_equal(%w[--skip-asset-pipeline --javascript=esbuild], opts.to_args)
  end

  def test_assigning_nil_database_disables_active_record
    opts = build_rails_options
    opts.database = nil

    assert(opts.skip_active_record?)
    assert_equal(["--skip-active-record"], opts.to_args)
  end

  def test_database_can_be_specified
    opts = build_rails_options
    opts.database = :postgresql

    assert_equal(["--database=postgresql"], opts.to_args)
  end

  def test_invalid_database_raises
    opts = build_rails_options

    assert_raises(ArgumentError) { opts.database = :rds }
  end

  def test_optional_frameworks_can_be_skipped
    opts = build_rails_options
    opts.skip_default_feature!(:action_mailer)
    opts.skip_default_feature!(:action_mailbox)
    opts.skip_default_feature!(:action_text)
    opts.skip_default_feature!(:active_job)
    opts.skip_default_feature!(:active_storage)
    opts.skip_default_feature!(:action_cable)
    opts.skip_default_feature!(:brakeman)
    opts.skip_default_feature!(:ci)
    opts.skip_default_feature!(:hotwire)
    opts.skip_default_feature!(:jbuilder)
    opts.skip_default_feature!(:rubocop)

    assert_equal(
      %w[
        --skip-action-mailer
        --skip-action-mailbox
        --skip-action-text
        --skip-active-job
        --skip-active-storage
        --skip-action-cable
        --skip-brakeman
        --skip-ci
        --skip-hotwire
        --skip-jbuilder
        --skip-rubocop
      ],
      opts.to_args
    )
  end

  def test_invalid_optional_frameworks_raises
    opts = build_rails_options

    assert_raises(ArgumentError) { opts.skip_default_feature!(:action_blah) }
  end

  def test_test_framework_can_be_set_to_minitest
    opts = build_rails_options
    opts.test_framework = :minitest

    assert_empty(opts.to_args)
  end

  def test_test_framework_can_be_set_to_rspec
    opts = build_rails_options
    opts.test_framework = :rspec

    assert(opts.rspec?)
    assert_equal(["--skip-test"], opts.to_args)
  end

  def test_test_framework_can_be_set_to_nil
    opts = build_rails_options
    opts.test_framework = nil

    assert_equal(["--skip-test"], opts.to_args)
  end

  def test_invalid_test_framework_raises
    opts = build_rails_options

    assert_raises(ArgumentError) { opts.test_framework = :mocha }
  end

  def test_system_test_can_be_skipped
    opts = build_rails_options
    opts.skip_system_test!

    assert(opts.skip_system_test?)
    assert_equal(["--skip-system-test"], opts.to_args)
  end

  def test_devcontainer_is_opt_in
    opts = build_rails_options
    opts.enable_optional_feature!(:devcontainer)

    assert_equal(["--devcontainer"], opts.to_args)
  end

  def test_defaults
    opts = build_rails_options

    refute(opts.api?)
    refute(opts.requires_node?)
    refute(opts.rspec?)
    refute(opts.skip_active_record?)
    refute(opts.skip_asset_pipeline?)
    refute(opts.skip_javascript?)
    refute(opts.skip_system_test?)

    assert_empty(opts.to_args)
  end

  def test_delegates_to_rails_version
    current_version = Nextgen::RailsVersion.current
    opts = Nextgen::RailsOptions.new(version: current_version)

    assert_equal current_version.label, opts.version_label
    assert_equal current_version.asset_pipelines, opts.asset_pipelines
    assert_equal current_version.databases, opts.databases
    assert_equal current_version.default_features, opts.default_features
    assert_equal current_version.optional_features, opts.optional_features
  end

  def test_using_edge_version_adds_edge_arg
    opts = Nextgen::RailsOptions.new(version: Nextgen::RailsVersion.edge)

    assert_includes opts.to_args, "--edge"
  end

  def test_does_not_use_asset_pipeline_arg_when_propshaft_is_the_only_supported_option
    version = Nextgen::RailsVersion.current.dup
    version.asset_pipelines = {propshaft: "Propshaft (default)"}
    opts = Nextgen::RailsOptions.new(version:)

    opts.asset_pipeline = :propshaft

    refute_includes opts.to_args, "--asset-pipeline=propshaft"
  end

  private

  def build_rails_options
    Nextgen::RailsOptions.new(version: Nextgen::RailsVersion.current)
  end

  def assert_prohibited(&)
    error = assert_raises(ArgumentError, &)
    assert_match(/Can't specify/i, error.message)
  end
end
