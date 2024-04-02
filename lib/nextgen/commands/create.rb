require "active_support/core_ext/string/inflections"
require "fileutils"
require "forwardable"
require "shellwords"
require "open3"
require "tmpdir"
require "tty-prompt"
require "rainbow"
require "nextgen/ext/prompt/list"
require "nextgen/ext/prompt/multilist"

module Nextgen
  class Commands::Create
    extend Forwardable
    include Commands::Helpers

    def self.run(app_path, options)
      new(app_path, options).run
    end

    def initialize(app_path, options)
      @app_path = File.expand_path(app_path)
      @app_name = File.basename(@app_path).gsub(/\W/, "_").squeeze("_").camelize
      @rails_opts = RailsOptions.new
      @style = options[:style]
    end

    def run # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
      say_banner
      continue_if "Ready to start?"

      ask_rails_version
      ask_database
      ask_full_stack_or_api
      ask_frontend_management unless rails_opts.api?
      ask_css unless rails_opts.api? || rails_opts.skip_asset_pipeline?
      ask_javascript unless rails_opts.api? || rails_opts.skip_asset_pipeline?
      ask_rails_frameworks
      ask_test_framework
      ask_system_testing if rails_opts.frontend? && rails_opts.test_framework?
      say

      if prompt.yes?("More enhancements? [ job, code snippets, gems ... ] ↵")
        ask_styled_enhancements
      end

      say_summary
      say_node if node?
      continue_if "Continue?"

      create_initial_commit_message
      copy_package_json if node?
      Nextgen::Rails.run "new", *rails_new_args
      Dir.chdir(app_path) do
        generators.each_value do |g|
          Nextgen::Rails.run "app:template", "LOCATION=#{write_generators_script(g)}"
        end
      end
      say_done
    end

    private

    attr_accessor :app_path, :app_name, :rails_opts, :generators

    def_delegators :shell, :say, :set_color

    def ask_rails_version
      selected = prompt.select(
        "What #{underline("version")} of Rails will you use?",
        Rails.version => :current,
        "edge (#{Rails.edge_branch} branch)" => :edge
      )
      rails_opts.edge! if selected == :edge
    end

    def ask_database
      databases = {
        "SQLite3 (default)" => "sqlite3",
        "PostgreSQL (recommended)" => "postgresql",
        **%w[MySQL Trilogy Oracle SQLServer JDBCMySQL JDBCSQLite3 JDBCPostgreSQL JDBC].to_h do |name|
          [name, name.downcase]
        end,
        "None (disable Active Record)" => nil
      }
      rails_opts.database = select(
        "Which #{underline("database")}?", databases
      )
    end

    def ask_full_stack_or_api
      api = select(
        "What style of Rails app do you need?",
        "Standard, full-stack Rails (default)" => false,
        "API only" => true
      )
      rails_opts.api! if api
      @generators = {basic: Generators.compatible_with(rails_opts: rails_opts, style: nil, scope: "basic")}
    end

    def ask_frontend_management
      frontend = select(
        "How will you manage frontend #{underline("assets")}?",
        "Sprockets (default)" => "sprockets",
        "Propshaft" => "propshaft",
        "Vite" => :vite
      )

      if frontend == :vite
        rails_opts.asset_pipeline = nil
        rails_opts.javascript = "vite"
      else
        rails_opts.asset_pipeline = frontend
      end
    end

    def ask_css
      rails_opts.css = select(
        "Which #{underline("CSS")} framework will you use with the asset pipeline?",
        "None (default)" => nil,
        "Bootstrap" => "bootstrap",
        "Bulma" => "bulma",
        "PostCSS" => "postcss",
        "Sass" => "sass",
        "Tailwind" => "tailwind"
      )
      generators[:basic].ask_second_level_questions(for_selected: rails_opts.css, prompt: prompt)
    end

    def ask_javascript
      rails_opts.javascript = select(
        "Which #{underline("JavaScript")} bundler will you use with the asset pipeline?",
        "Importmap (default)" => "importmap",
        "Bun" => "bun",
        "ESBuild" => "esbuild",
        "Rollup" => "rollup",
        "Webpack" => "webpack",
        "None" => nil
      )
    end

    def ask_rails_frameworks
      frameworks = {
        "JBuilder" => "jbuilder",
        "Action Mailer" => "action_mailer",
        "Active Job" => "active_job",
        "Action Cable" => "action_cable"
      }

      unless rails_opts.api? || rails_opts.skip_javascript?
        frameworks = {"Hotwire" => "hotwire"}.merge(frameworks)
      end

      unless rails_opts.skip_active_record?
        frameworks.merge!(
          "Active Storage" => "active_storage",
          "Action Text" => "action_text",
          "Action Mailbox" => "action_mailbox"
        )
      end

      answers = multi_select(
        "Which optional Rails #{underline("frameworks")} do you need?",
        frameworks,
        default: frameworks.keys.reverse
      )

      (frameworks.values - answers).each { rails_opts.skip_optional_framework!(_1) }
    end

    def ask_test_framework
      rails_opts.test_framework = select(
        "Which #{underline("test")} framework will you use?",
        "Minitest (default)" => "minitest",
        "RSpec" => "rspec",
        "None" => nil
      )
    end

    def ask_system_testing
      system_testing = select(
        "Include #{underline("system testing")} (capybara)?",
        "Yes (default)" => true,
        "No" => false
      )
      rails_opts.skip_system_test! unless system_testing
    end

    def ask_styled_enhancements
      say "  ↪ style: #{cyan(@style || "default")}"
      Nextgen.scopes_for(style: @style).each do |scope|
        gen = Generators.compatible_with(rails_opts: rails_opts, style: @style, scope: scope)
        next if gen.empty? || scope == "basic"

        key_word = underline(scope.tr("_", " "))
        multi = scope == scope.pluralize
        sort = gen.optional.size > 10
        gen.ask_select("Which #{key_word} would you like to add?", prompt: prompt, multi: multi, sort: sort)
        generators[scope.to_sym] = gen
      end
    end
  end
end
