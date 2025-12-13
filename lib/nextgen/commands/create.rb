# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "fileutils"
require "forwardable"
require "shellwords"
require "open3"
require "tmpdir"
require "tty-prompt"
require "nextgen/ext/prompt/list"
require "nextgen/ext/prompt/multilist"

module Nextgen
  class Commands::Create # rubocop:disable Metrics/ClassLength
    extend Forwardable
    RESERVED_NAMES = %w[application destroy plugin runner test]

    def self.run(app_path, options)
      new(app_path, options).run
    end

    def initialize(app_path, _options)
      @app_path = File.expand_path(app_path)
      @app_name = File.basename(@app_path).gsub(/\W/, "_").squeeze("_").camelize
    end

    def run # rubocop:disable Metrics/MethodLength, Metrics/PerceivedComplexity
      reserved_word_message if app_name_is_reserved_word?

      say <<~BANNER
        Welcome to nextgen, the interactive Rails app generator!

        You are about to create a Rails app named "#{cyan(app_name)}" in the following directory:

          #{cyan(app_path)}

        You'll be asked ~10 questions about database, test framework, and other options.
        The standard Rails "omakase" experience will be selected by default.

      BANNER

      continue_if "Ready to start?"

      rails_version = ask_rails_version
      @rails_opts = RailsOptions.new(version: rails_version)

      ask_database
      ask_full_stack_or_api
      ask_frontend_management unless rails_opts.api?
      ask_css unless rails_opts.api? || rails_opts.skip_asset_pipeline?
      ask_javascript unless rails_opts.api? || rails_opts.skip_asset_pipeline?
      ask_rails_features
      ask_rails_frameworks
      ask_test_framework
      ask_system_testing if rails_opts.frontend? && rails_opts.test_framework?
      reload_generators
      ask_optional_enhancements
      ask_js_package_manager if node?
      reload_generators

      say <<~SUMMARY

        OK! Your Rails app is ready to be created.
        The following options will be passed to `rails new`:

          #{rails_new_args.join("\n  ")}

        The following nextgen enhancements will also be applied in individual git commits via `rails app:template`:

          #{selected_generators.join(", ").scan(/\S.{0,75}(?:,|$)/).join("\n  ")}

      SUMMARY

      if node?
        say <<~NODE
          Based on the options you selected, your app will require a JavaScript runtime. For reference, you are using:

            node: #{capture_version("node")}
            yarn: #{capture_version("yarn")}
            npm:  #{capture_version("npm")}

        NODE
      end

      continue_if "Continue?"

      create_initial_commit_message
      create_package_json if node?
      Nextgen::RailsCommand.run "new", *rails_new_args
      Dir.chdir(app_path) do
        Nextgen::RailsCommand.run "app:template", "LOCATION=#{write_generators_script}"
      end

      say <<~DONE.gsub(/^/, "  ")


        #{green("Done!")}

        A Rails #{rails_opts.version_label} app was generated in #{cyan(app_path)}.
        Run #{yellow("bin/setup")} in that directory to get started.


      DONE
    end

    private

    attr_accessor :app_path, :app_name, :rails_opts, :generators

    def_delegators :shell, :say

    def app_name_is_reserved_word?
      RESERVED_NAMES.include?(app_name.downcase)
    end

    def reserved_word_message
      say <<~APP_NAME
        Your Rails app name: "#{cyan(app_name)}", is a reserved word. Please rerun the initial command with an unreserved word instead.
      APP_NAME
      exit
    end

    def continue_if(question)
      if prompt.yes?(question)
        say
      else
        say "Canceled", :red
        exit
      end
    end

    def create_package_json
      FileUtils.mkdir_p(app_path)
      FileUtils.cp(
        Nextgen.template_path.join("package.json"),
        File.join(app_path, "package.json")
      )
      FileUtils.touch(File.join(app_path, rails_opts.npm? ? "package-lock.json" : "yarn.lock"))
    end

    def ask_rails_version
      options = %i[current edge main].to_h do |key|
        version = RailsVersion.public_send(key)
        [version.label, version]
      end
      prompt.select("What version of Rails will you use?", options)
    end

    def ask_database
      common_databases = rails_opts.databases.slice(:sqlite3, :postgresql, :mysql).invert
      all_databases = rails_opts.databases.invert.merge("None (disable Active Record)" => nil)
      rails_opts.database =
        prompt_select("Which database?", common_databases.merge("More options..." => false)) ||
        prompt_select("Which database?", all_databases)
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
      options = rails_opts.asset_pipelines.invert.merge("Vite" => :vite)
      frontend = prompt_select("How will you manage frontend assets?", options)

      if frontend == :vite
        rails_opts.vite!
      else
        rails_opts.asset_pipeline = frontend
      end
    end

    def ask_css
      rails_opts.css = prompt_select(
        "Which CSS framework will you use with the asset pipeline?",
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
        "Which JavaScript bundler will you use with the asset pipeline?",
        "Importmap (default)" => "importmap",
        "Bun" => "bun",
        "ESBuild" => "esbuild",
        "Rollup" => "rollup",
        "Webpack" => "webpack",
        "None" => nil
      )
    end

    def ask_rails_features
      opt_out = rails_opts.default_features.invert
      opt_in = rails_opts.optional_features.invert

      answers = prompt.multi_select(
        "Rails can preinstall the following. Which do you need?",
        opt_out.merge(opt_in),
        default: opt_out.keys.reverse
      )

      (opt_out.values - answers).each { rails_opts.skip_default_feature!(_1) }
      (opt_in.values & answers).each { rails_opts.enable_optional_feature!(_1) }
    end

    def ask_rails_frameworks
      frameworks = {
        "JBuilder" => :jbuilder,
        "Action Mailer" => :action_mailer,
        "Active Job" => :active_job,
        "Action Cable" => :action_cable
      }

      unless rails_opts.api? || rails_opts.skip_javascript?
        frameworks = {"Hotwire" => :hotwire}.merge(frameworks)
      end

      unless rails_opts.skip_active_record?
        frameworks.merge!(
          "Active Storage" => :active_storage,
          "Action Text" => :action_text,
          "Action Mailbox" => :action_mailbox
        )
      end

      answers = prompt.multi_select(
        "Which optional Rails frameworks do you need?",
        frameworks,
        default: frameworks.keys.reverse
      )

      (frameworks.values - answers).each { rails_opts.skip_default_feature!(_1) }
    end

    def ask_test_framework
      rails_opts.test_framework = prompt_select(
        "Which test framework will you use?",
        "Minitest (default)" => :minitest,
        "RSpec" => :rspec,
        "None" => nil
      )
    end

    def ask_system_testing
      system_testing = prompt_select(
        "Include system testing (capybara)?",
        "Yes (default)" => true,
        "No" => false
      )
      rails_opts.skip_system_test! unless system_testing
    end

    def reload_generators
      selected = generators ? (generators.all_active & generators.optional.values) : []
      @generators = Generators.compatible_with(rails_opts:)
      generators.activate(*(selected & generators.optional.values))
    end

    def ask_optional_enhancements
      answers = prompt.multi_select(
        "Which optional enhancements would you like to add?",
        generators.optional.sort_by { |label, _| label.downcase }.to_h
      )
      generators.activate(*answers)
    end

    def ask_js_package_manager
      options = {
        "yarn (default)" => :yarn,
        "npm" => :npm
      }
      rails_opts.js_package_manager = prompt_select("Which JavaScript package manager will you use?", options)
    end

    def create_initial_commit_message
      path = File.join(app_path, "tmp", "initial_nextgen_commit")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, <<~COMMIT)
        Init project with `rails new` (#{rails_opts.version_label})

        Nextgen generated this project with the following `rails new` options:

        ```
        #{rails_opts.to_args.join("\n")}
        ```
      COMMIT
    end

    def rails_new_args
      [app_path, "--no-rc", *rails_opts.to_args].tap do |args|
        # Work around a Rails bug where --edge and --main cause --no-rc to get ignored.
        # Specifying --rc= with a non-existent file has the same effect as --no-rc.
        @rc_token ||= SecureRandom.hex(8)
        args << "--rc=#{@rc_token}" if args.intersect?(%w[--edge --main])
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

    def cyan(string) = shell.set_color(string, :cyan)
    def green(string) = shell.set_color(string, :green)
    def yellow(string) = shell.set_color(string, :yellow)
    def prompt_select(question, choices) = prompt.select(question, choices, cycle: true)
  end
end
