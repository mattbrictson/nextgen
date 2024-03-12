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

    def initialize(app_path, _options)
      @app_path = File.expand_path(app_path)
      @app_name = File.basename(@app_path).gsub(/\W/, "_").squeeze("_").camelize
      @rails_opts = RailsOptions.new
      @generators = {basic: Generators.compatible_with(rails_opts: rails_opts, scope: "basic")}
    end

    def run # rubocop:disable Metrics/MethodLength Metrics/PerceivedComplexity
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

      if prompt.yes?("More detailed configuration? [ cache, job and gems ] ↵")
        ask_job_backend if rails_opts.active_job?
        ask_workflows
        ask_checkers
        ask_code_snippets
        ask_optional_enhancements
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

    def ask_job_backend
      generators[:job] = Generators.compatible_with(rails_opts: rails_opts, scope: "job").tap do |it|
        it.ask_select("Which #{underline("job backend")} would you like to use?", prompt: prompt)
      end
    end

    def ask_workflows
      generators[:workflows] = Generators.compatible_with(rails_opts: rails_opts, scope: "workflows").tap do |it|
        it.ask_select("Which #{underline("workflows")} would you like to add?", multi: true, prompt: prompt)
      end
    end

    def ask_checkers
      generators[:checkers] = Generators.compatible_with(rails_opts: rails_opts, scope: "checkers").tap do |it|
        it.ask_select("Which #{underline("checkers")} would you like to add?", multi: true, prompt: prompt)
      end
    end

    def ask_code_snippets
      generators[:code_snippets] = Generators.compatible_with(rails_opts: rails_opts, scope: "code_snippets").tap do |it|
        it.ask_select("Which #{underline("code snippets")} would you like to add?", multi: true, prompt: prompt)
      end
    end

    def ask_optional_enhancements
      generators[:gems] = Generators.compatible_with(rails_opts: rails_opts, scope: "gems").tap do |it|
        it.ask_select("Which optional enhancements would you like to add?", multi: true, sort: true, prompt: prompt)
      end
    end
  end
end
