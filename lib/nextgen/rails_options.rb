# frozen_string_literal: true

module Nextgen
  class RailsOptions
    DATABASES = %w[
      postgresql
      mysql
      trilogy
      sqlite3
      oracle
      sqlserver
      jdbcmysql
      jdbcsqlite3
      jdbcpostgresql
      jdbc
    ].freeze

    TEST_FRAMEWORKS = %w[minitest rspec].freeze

    ASSET_PIPELINES = %w[sprockets propshaft].freeze

    OPTIONAL_FRAMEWORKS = %w[
      action_mailer
      action_mailbox
      action_text
      active_job
      active_storage
      action_cable
      hotwire
      jbuilder
    ].freeze

    attr_reader :asset_pipeline, :css, :javascript, :database, :test_framework

    def initialize
      @api = false
      @edge = false
      @skip_frameworks = []
      @skip_system_test = false
      @test_framework = "minitest"
    end

    def asset_pipeline=(pipeline)
      raise ArgumentError, "Unknown asset pipeline: #{pipeline}" unless [nil, *ASSET_PIPELINES].include?(pipeline)

      @asset_pipeline = pipeline
    end

    def css=(framework)
      raise ArgumentError, "Can't specify css in API mode" if api?
      raise ArgumentError, "Can't specify css when asset pipeline is disabled" if skip_asset_pipeline?

      @css = framework
    end

    def javascript=(framework)
      raise ArgumentError, "Can't specify javascript in API mode" if api? && framework

      if skip_asset_pipeline? && framework != "vite"
        raise ArgumentError, "Can't specify javascript when asset pipeline is disabled"
      end

      @javascript = framework
    end

    def vite?
      @javascript == "vite"
    end

    def skip_javascript?
      defined?(@javascript) && @javascript.nil?
    end

    def database=(db)
      raise ArgumentError, "Unknown database: #{db}" unless [nil, *DATABASES].include?(db)

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

    def edge!
      @edge = true
    end

    def edge?
      @edge
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
      %w[bootstrap bulma postcss sass].include?(css) || %w[webpack esbuild rollup vite].include?(javascript)
    end

    def rspec?
      @test_framework == "rspec"
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
      defined?(@test_framework) && [nil, "rspec"].include?(@test_framework)
    end

    def system_testing?
      !(api? || test_framework.nil? || skip_system_test?)
    end

    def action_mailer?
      !skip_optional_framework?("action_mailer")
    end

    def active_job?
      !skip_optional_framework?("active_job")
    end

    def skip_optional_framework!(framework)
      raise ArgumentError, "Unknown framework: #{framework}" unless OPTIONAL_FRAMEWORKS.include?(framework)

      skip_frameworks << framework
    end

    def skip_optional_framework?(framework)
      raise ArgumentError, "Unknown framework: #{framework}" unless OPTIONAL_FRAMEWORKS.include?(framework)

      skip_frameworks.include?(framework)
    end

    def to_args # rubocop:disable Metrics/PerceivedComplexity
      [].tap do |args|
        args << "--edge" if edge?
        args << "--api" if api?
        args << "--skip-active-record" if skip_active_record?
        args << "--skip-asset-pipeline" if skip_asset_pipeline?
        args << "--skip-javascript" if skip_javascript?
        args << "--skip-test" if skip_test?
        args << "--skip-system-test" if skip_system_test?
        args << "--asset-pipeline=#{asset_pipeline}" if asset_pipeline
        args << "--database=#{database}" if database
        args << "--css=#{css}" if css
        args << "--javascript=#{javascript}" if javascript
        args.push(*skip_frameworks.map { "--skip-#{_1.tr("_", "-")}" })
      end
    end

    private

    attr_reader :skip_frameworks
  end
end
