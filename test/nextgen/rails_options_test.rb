# frozen_string_literal: true

require "test_helper"

class Nextgen::RailsOptionsTest < Minitest::Test
  def test_api_mode_can_be_specified
    opts = Nextgen::RailsOptions.new
    opts.api!

    assert(opts.api?)
    assert_equal(["--api"], opts.to_args)
  end

  def test_api_mode_prohibits_frontend_options
    opts = Nextgen::RailsOptions.new
    opts.api!

    assert_prohibited { opts.css = "sass" }
    assert_prohibited { opts.javascript = "esbuild" }
  end

  def test_css_prohibits_api_mode
    opts = Nextgen::RailsOptions.new
    opts.css = "sass"

    assert_prohibited { opts.api! }
  end

  def test_javascript_prohibits_api_mode
    opts = Nextgen::RailsOptions.new
    opts.javascript = "esbuild"

    assert_prohibited { opts.api! }
  end

  def test_node_requirement_depends_on_css_option
    %w[bootstrap bulma postcss sass].each do |css|
      opts = Nextgen::RailsOptions.new
      opts.css = css

      assert(opts.requires_node?)
    end

    opts = Nextgen::RailsOptions.new
    opts.css = "tailwind"

    refute(opts.requires_node?)
  end

  def test_node_requirement_depends_on_javascript_option
    %w[webpack esbuild rollup vite].each do |js|
      opts = Nextgen::RailsOptions.new
      opts.javascript = js

      assert(opts.requires_node?)
    end

    opts = Nextgen::RailsOptions.new
    opts.javascript = "importmap"

    refute(opts.requires_node?)
  end

  def test_css_can_be_specified
    opts = Nextgen::RailsOptions.new
    opts.css = "bulma"

    assert_equal(["--css=bulma"], opts.to_args)
  end

  def test_javascript_can_be_specified
    opts = Nextgen::RailsOptions.new
    opts.javascript = "esbuild"

    assert_equal(["--javascript=esbuild"], opts.to_args)
  end

  def test_javascript_can_be_skipped_by_assigning_nil
    opts = Nextgen::RailsOptions.new
    opts.javascript = nil

    assert(opts.skip_javascript?)
    assert_equal(["--skip-javascript"], opts.to_args)
  end

  def test_asset_pipeline_can_be_specified
    opts = Nextgen::RailsOptions.new

    opts.asset_pipeline = "sprockets"
    assert_equal(["--asset-pipeline=sprockets"], opts.to_args)

    opts.asset_pipeline = "propshaft"
    assert_equal(["--asset-pipeline=propshaft"], opts.to_args)
  end

  def test_invalid_asset_pipeline_raises
    opts = Nextgen::RailsOptions.new

    assert_raises(ArgumentError) { opts.asset_pipeline = "something" }
  end

  def test_assigning_nil_disables_asset_pipeline_allows_vite_but_prohibits_other_frontend_options
    opts = Nextgen::RailsOptions.new
    opts.asset_pipeline = nil

    assert_prohibited { opts.css = "sass" }
    assert_prohibited { opts.javascript = "esbuild" }

    opts.javascript = "vite"
    assert(opts.skip_asset_pipeline?)
    assert_equal(["--skip-asset-pipeline", "--javascript=vite"], opts.to_args)
  end

  def test_assigning_nil_database_disables_active_record
    opts = Nextgen::RailsOptions.new
    opts.database = nil

    assert(opts.skip_active_record?)
    assert_equal(["--skip-active-record"], opts.to_args)
  end

  def test_database_can_be_specified
    opts = Nextgen::RailsOptions.new
    opts.database = "postgresql"

    assert_equal(["--database=postgresql"], opts.to_args)
  end

  def test_invalid_database_raises
    opts = Nextgen::RailsOptions.new

    assert_raises(ArgumentError) { opts.database = "rds" }
  end

  def test_optional_frameworks_can_be_skipped
    opts = Nextgen::RailsOptions.new
    opts.skip_optional_feature!("action_mailer")
    opts.skip_optional_feature!("action_mailbox")
    opts.skip_optional_feature!("action_text")
    opts.skip_optional_feature!("active_job")
    opts.skip_optional_feature!("active_storage")
    opts.skip_optional_feature!("action_cable")
    opts.skip_optional_feature!("brakeman")
    opts.skip_optional_feature!("ci")
    opts.skip_optional_feature!("hotwire")
    opts.skip_optional_feature!("jbuilder")
    opts.skip_optional_feature!("rubocop")

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
    opts = Nextgen::RailsOptions.new

    assert_raises(ArgumentError) { opts.skip_optional_feature!("action_blah") }
  end

  def test_test_framework_can_be_set_to_minitest
    opts = Nextgen::RailsOptions.new
    opts.test_framework = "minitest"

    assert_empty(opts.to_args)
  end

  def test_test_framework_can_be_set_to_rspec
    opts = Nextgen::RailsOptions.new
    opts.test_framework = "rspec"

    assert(opts.rspec?)
    assert_equal(["--skip-test"], opts.to_args)
  end

  def test_test_framework_can_be_set_to_nil
    opts = Nextgen::RailsOptions.new
    opts.test_framework = nil

    assert_equal(["--skip-test"], opts.to_args)
  end

  def test_invalid_test_framework_raises
    opts = Nextgen::RailsOptions.new

    assert_raises(ArgumentError) { opts.test_framework = "mocha" }
  end

  def test_system_test_can_be_skipped
    opts = Nextgen::RailsOptions.new
    opts.skip_system_test!

    assert(opts.skip_system_test?)
    assert_equal(["--skip-system-test"], opts.to_args)
  end

  def test_defaults
    opts = Nextgen::RailsOptions.new

    refute(opts.api?)
    refute(opts.requires_node?)
    refute(opts.rspec?)
    refute(opts.skip_active_record?)
    refute(opts.skip_asset_pipeline?)
    refute(opts.skip_javascript?)
    refute(opts.skip_system_test?)

    assert_empty(opts.to_args)
  end

  private

  def assert_prohibited(&)
    error = assert_raises(ArgumentError, &)
    assert_match(/Can't specify/i, error.message)
  end
end
