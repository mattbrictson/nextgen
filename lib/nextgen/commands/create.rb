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
  class Commands::Create # rubocop:disable Metrics/ClassLength
    extend Forwardable

    def self.run(app_path, options)
      new(app_path, options).run
    end

    def initialize(app_path, _options)
      @app_path = File.expand_path(app_path)
      @app_name = File.basename(@app_path).gsub(/\W/, "_").squeeze("_").camelize
      @rails_opts = RailsOptions.new
    end

    def run # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
      say <<~BANNER
        Welcome to nextgen, the interactive Rails app generator!

        You are about to create a Rails app named "#{cyan(app_name)}" in the following directory:

          #{cyan(app_path)}

        You'll be asked ~10 questions about database, test framework, and other options.
        The standard Rails "omakase" experience will be selected by default.

      BANNER

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
      ask_optional_enhancements

      say <<~SUMMARY

        OK! Your Rails app is ready to be created.
        The following options will be passed to `rails new`:

          #{rails_new_args.join("\n  ")}

        The following nextgen enhancements will also be applied in individual git commits via `rails app:template`:

          #{selected_generators.join(", ").scan(/\S.{0,75}(?:,|$)/).join("\n  ")}

      SUMMARY

      if node?
        say <<~NODE
          Based on the options you selected, your app will require Node and Yarn. For reference, you are using these versions:

            Node: #{capture_version("node")}
            Yarn: #{capture_version("yarn")}

        NODE
      end

      continue_if "Continue?"

      create_initial_commit_message
      copy_package_json if node?
      Nextgen::Rails.run "new", *rails_new_args
      Dir.chdir(app_path) do
        Nextgen::Rails.run "app:template", "LOCATION=#{write_generators_script}"
      end

      say <<~DONE.gsub(/^/, "  ")


        #{green("Done!")}

        A Rails #{rails_version} app was generated in #{cyan(app_path)}.
        Run #{set_color("bin/setup", :yellow)} in that directory to get started.


      DONE
    end

    private

    attr_accessor :app_path, :app_name, :rails_opts, :generators

    def_delegators :shell, :say, :set_color

    def continue_if(question)
      if prompt.yes?("#{question} ↵")
        say
      else
        say "Canceled", :red
        exit
      end
    end

    def copy_package_json
      FileUtils.mkdir_p(app_path)
      FileUtils.cp(
        Nextgen.template_path.join("package.json"),
        File.join(app_path, "package.json")
      )
    end

    def rails_version
      rails_opts.edge? ? "edge (#{Rails.edge_branch} branch)" : Rails.version
    end

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
      rails_opts.database = prompt_select(
        "Which #{underline("database")}?", databases
      )
    end

    def ask_full_stack_or_api
      api = prompt_select(
        "What style of Rails app do you need?",
        "Standard, full-stack Rails (default)" => false,
        "API only" => true
      )
      rails_opts.api! if api
    end

    def ask_frontend_management
      frontend = prompt_select(
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
      rails_opts.css = prompt_select(
        "Which #{underline("CSS")} framework will you use with the asset pipeline?",
        "None (default)" => nil,
        "Bootstrap" => "bootstrap",
        "Bulma" => "bulma",
        "PostCSS" => "postcss",
        "Sass" => "sass",
        "Tailwind" => "tailwind"
      )
    end

    def ask_javascript
      rails_opts.javascript = prompt_select(
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

      answers = prompt.multi_select(
        "Which optional Rails #{underline("frameworks")} do you need?",
        frameworks,
        default: frameworks.keys.reverse
      )

      (frameworks.values - answers).each { rails_opts.skip_optional_framework!(_1) }
    end

    def ask_test_framework
      rails_opts.test_framework = prompt_select(
        "Which #{underline("test")} framework will you use?",
        "Minitest (default)" => "minitest",
        "RSpec" => "rspec",
        "None" => nil
      )
    end

    def ask_system_testing
      system_testing = prompt_select(
        "Include #{underline("system testing")} (capybara)?",
        "Yes (default)" => true,
        "No" => false
      )
      rails_opts.skip_system_test! unless system_testing
    end

    def ask_optional_enhancements
      @generators = Generators.compatible_with(rails_opts: rails_opts)

      answers = prompt.multi_select(
        "Which optional enhancements would you like to add?",
        generators.optional.sort_by { |label, _| label.downcase }.to_h
      )
      generators.activate(*answers)
    end

    def create_initial_commit_message
      path = File.join(app_path, "tmp", "initial_nextgen_commit")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, <<~COMMIT)
        Init project with `rails new` (#{Nextgen::Rails.version})

        Nextgen generated this project with the following `rails new` options:

        ```
        #{rails_opts.to_args.join("\n")}
        ```
      COMMIT
    end

    def rails_new_args
      [app_path, "--no-rc", *rails_opts.to_args].tap do |args|
        # Work around a Rails bug where --edge causes --no-rc to get ignored.
        # Specifying --rc= with a non-existent file has the same effect as --no-rc.
        @rc_token ||= SecureRandom.hex(8)
        args << "--rc=#{@rc_token}" if rails_opts.edge?
      end
    end

    def node?
      generators.node_active?
    end

    def capture_version(command)
      out, _err, status = Open3.capture3(command, "--version")
      version = status.success? && out[/\d[.\d]+\d/]

      version || "<unknown>"
    end

    def selected_generators
      optional = generators.optional.invert
      selected = generators.all_active.filter_map { |name| optional[name] }

      selected.any? ? selected.sort_by(&:downcase) : ["<None>"]
    end

    def write_generators_script
      new_tempfile_path.tap do |location|
        File.write(location, generators.to_ruby_script)
      end
    end

    def new_tempfile_path
      token = SecureRandom.hex(8)
      File.join(Dir.tmpdir, "nextgen_create_#{token}.rb")
    end

    def prompt
      @prompt ||= TTY::Prompt.new
    end

    def shell
      @shell ||= Thor::Base.shell.new
    end

    def green(string) = set_color(string, :green)
    def cyan(string) = set_color(string, :cyan)
    def underline(string) = Rainbow(string).underline
    def prompt_select(question, choices) = prompt.select(question, choices, enum: ".", cycle: true)
  end
end
