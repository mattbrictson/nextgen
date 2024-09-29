# frozen_string_literal: true

require "forwardable"

module Nextgen
  class RailsOptions
    extend Forwardable

    TEST_FRAMEWORKS = %i[minitest rspec].freeze

    FRAMEWORKS = %i[
      action_mailer
      action_mailbox
      action_text
      active_job
      active_storage
      action_cable
      hotwire
      jbuilder
    ].freeze

    JS_PACKAGE_MANAGERS = %i[npm yarn].freeze

    attr_reader :asset_pipeline, :css, :javascript, :js_package_manager, :database, :test_framework

    def_delegators :version, :asset_pipelines, :databases, :default_features, :optional_features

    def initialize(version:)
      @version = version
      @api = false
      @vite = false
      @enable_features = []
      @skip_features = []
      @skip_system_test = false
      @test_framework = :minitest
      @js_package_manager = :yarn
    end

    def version_label
      version.label
    end

    def asset_pipeline=(pipeline)
      raise ArgumentError, "Unknown asset pipeline: #{pipeline}" unless [nil, *asset_pipelines.keys].include?(pipeline)

      @asset_pipeline = pipeline
    end

    def css=(framework)
      raise ArgumentError, "Can't specify css in API mode" if api?
      raise ArgumentError, "Can't specify css when asset pipeline is disabled" if skip_asset_pipeline?

      @css = framework
    end

    def javascript=(framework)
      raise ArgumentError, "Can't specify javascript in API mode" if api? && framework
      raise ArgumentError, "Can't specify javascript when asset pipeline is disabled" if skip_asset_pipeline?

      @javascript = framework
    end

    def js_package_manager=(tool)
      raise ArgumentError, "Unknown package manager: #{tool}" unless JS_PACKAGE_MANAGERS.include?(tool)

      @js_package_manager = tool
    end

    def npm?
      js_package_manager == :npm
    end

    def vite!
      self.asset_pipeline = nil
      @javascript = "esbuild"
      @vite = true
    end

    def vite?
      @vite
    end

    def skip_javascript?
      defined?(@javascript) && @javascript.nil?
    end

    def database=(db)
      raise ArgumentError, "Unknown database: #{db}" unless [nil, *databases.keys].include?(db)

      @database = db
    end

    def postgresql?
      database == "postgresql"
    end

    def test_framework=(framework)
      raise ArgumentError, "Unknown test framework: #{framework}" unless [nil, *TEST_FRAMEWORKS].include?(framework)

      @test_framework = framework
    end

    def test_framework?
      !!@test_framework
    end

    def devcontainer!
      @devcontainer = true
    end

    def api!
      raise ArgumentError, "Can't specify API mode if css is already specified" if css
      raise ArgumentError, "Can't specify API mode if javascript is already specified" if javascript

      @api = true
    end

    def api?
      @api
    end

    def frontend?
      !api?
    end

    def requires_node?
      %w[bootstrap bulma postcss sass].include?(css) || %w[webpack esbuild rollup].include?(javascript)
    end

    def minitest?
      @test_framework == :minitest
    end

    def rspec?
      @test_framework == :rspec
    end

    def rubocop?
      !skip_default_feature?(:rubocop)
    end

    def active_record?
      !skip_active_record?
    end

    def skip_active_record?
      defined?(@database) && @database.nil?
    end

    def skip_asset_pipeline?
      defined?(@asset_pipeline) && @asset_pipeline.nil?
    end

    def skip_system_test!
      @skip_system_test = true
    end

    def skip_system_test?
      @skip_system_test
    end

    def skip_test?
      defined?(@test_framework) && [nil, :rspec].include?(@test_framework)
    end

    def system_testing?
      !(api? || test_framework.nil? || skip_system_test?)
    end

    def action_mailer?
      !skip_default_feature?(:action_mailer)
    end

    def active_job?
      !skip_default_feature?(:active_job)
    end

    def skip_kamal?
      # Depending on the Rails version, kamal may not exist, in which case we can consider it "skipped".
      !skippable_features.include?(:kamal) || skip_default_feature?(:kamal)
    end

    def skip_solid?
      !skippable_features.include?(:solid) || skip_default_feature?(:solid)
    end

    def enable_optional_feature!(feature)
      raise ArgumentError, "Unknown feature: #{feature}" unless optional_features.include?(feature)

      enable_features << feature
    end

    def skip_default_feature!(feature)
      raise ArgumentError, "Unknown feature: #{feature}" unless skippable_features.include?(feature)

      skip_features << feature
    end

    def skip_default_feature?(feature)
      raise ArgumentError, "Unknown feature: #{feature}" unless skippable_features.include?(feature)

      skip_features.include?(feature)
    end

    def to_args # rubocop:disable Metrics/PerceivedComplexity
      [].tap do |args|
        args.push(*version.args)
        args << "--api" if api?
        args << "--skip-active-record" if skip_active_record?
        args << "--skip-asset-pipeline" if skip_asset_pipeline?
        args << "--skip-javascript" if skip_javascript?
        args << "--skip-test" if skip_test?
        args << "--skip-system-test" if skip_system_test?
        args << "--asset-pipeline=#{asset_pipeline}" if asset_pipeline && asset_pipeline != asset_pipelines.keys.first
        args << "--database=#{database}" if database
        args << "--css=#{css}" if css
        args << "--javascript=#{javascript}" if javascript
        args.push(*enable_features.map { "--#{_1.to_s.tr("_", "-")}" })
        args.push(*skip_features.map { "--skip-#{_1.to_s.tr("_", "-")}" })
      end
    end

    private

    attr_reader :enable_features, :skip_features, :version

    def skippable_features
      FRAMEWORKS + default_features.keys
    end
  end
end
