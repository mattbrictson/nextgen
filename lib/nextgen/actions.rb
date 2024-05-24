# frozen_string_literal: true

module Nextgen
  module Actions
    include Bundler
    include Git
    include Yarn

    def with_nextgen_source_path
      path = Nextgen.template_path.to_s
      source_paths.unshift(path)
      yield
    ensure
      source_paths.shift if source_paths[0] == path
    end

    # Like Thor's built-in `run`, but raises a descriptive exception if the command fails.
    def run!(cmd, env: {}, verbose: true, capture: false)
      if capture
        say_status :run, cmd, :green if verbose
        return if options[:pretend]

        require "open3"
        result, status = Open3.capture2e(env, cmd)
        success = status.success?
      else
        result = success = run(cmd, env:, verbose:)
      end

      return result if success

      say result if result.present?
      die "Failed to run command. Cannot continue. (#{cmd})"
    end

    def move(from, to)
      if File.exist?(to)
        say_status :skip, "#{to} exists", :yellow
        return
      end
      unless File.exist?(from)
        say_status :skip, "#{from} does not exit", :yellow
        return
      end

      say_status :move, [from, to].join(" → "), :green
      FileUtils.mv(from, to)
    end

    def minitest?
      File.exist?("test/test_helper.rb")
    end

    def rspec?
      File.exist?("spec/spec_helper.rb")
    end

    def copy_test_support_file(file)
      copy_action = file.end_with?(".tt") ? method(:template) : method(:copy_file)

      if minitest?
        create_test_support_directory
        copy_action.call "test/support/#{file}"
      elsif rspec?
        empty_directory "spec/support"
        spec_file_path = "spec/support/#{file}"
        if Nextgen.template_path.join(spec_file_path).exist?
          copy_action.call spec_file_path
        else
          copy_action.call "test/support/#{file}", spec_file_path.sub(/\.tt$/, "")
        end
      end
    end

    def create_test_support_directory
      empty_directory "test/support"
      return if File.exist?("test/test_helper.rb") && File.read("test/test_helper.rb").include?("support/**/*.rb")

      append_to_file "test/test_helper.rb", <<~RUBY

        Dir[File.expand_path("support/**/*.rb", __dir__)].sort.each { |rb| require(rb) }
      RUBY
    end

    def document_deploy_var(var_name, desc = nil, required: false, default: nil)
      insertion = "`#{var_name}`"
      insertion << " **REQUIRED**" if required
      insertion << " - #{desc}" if desc.present?
      insertion << " (default: #{default})" unless default.nil?

      copy_file "DEPLOYMENT.md" unless File.exist?("DEPLOYMENT.md")
      inject_into_file "DEPLOYMENT.md", "#{insertion}\n- ", after: /^## Environment variables.*?^- /m
    end

    def add_lint_task(task, fix: "#{task}:autocorrect")
      unless File.read("README.md").include?(" and lint checks")
        inject_into_file "README.md", " and lint checks", after: "automated tests"
        inject_into_file "README.md", <<~MARKDOWN, after: "```\nbin/rake\n```\n"

          > [!TIP]
          > Rake allows you to run all checks in parallel with the `-m` option. This is much faster, but since the output is interleaved, it may be harder to read.

          ```
          bin/rake -m
          ```

          ### Fixing lint issues

          Some lint issues can be auto-corrected. To fix them, run:

          ```
          bin/rake fix
          ```
        MARKDOWN
      end

      unless File.read("Rakefile").include?("task fix:")
        append_to_file "Rakefile", <<~RUBY

          desc "Apply auto-corrections"
          task fix: %w[] do
            Thor::Base.shell.new.say_status :OK, "All fixes applied!"
          end
        RUBY
      end

      inject_into_file "Rakefile", " #{task}", after: /task default: %w\[[^\]]*/
      inject_into_file "Rakefile", " #{fix}", after: /task fix: %w\[[^\]]*/
    end

    def gitignore(*lines)
      return unless File.exist?(".gitignore")

      lines -= File.read(".gitignore").lines(chomp: true)
      return if lines.empty?

      text = lines.map(&:strip).join("\n")
      append_to_file ".gitignore", "#{text}\n"
    end

    def prevent_autoload_lib(*paths)
      return unless File.read("config/application.rb").match?(/^\s*config.autoload_lib/)

      paths.reverse_each do |path|
        gsub_file("config/application.rb", /autoload_lib\(ignore: %w.*$/) do |match|
          next match if match.match?(/%w.*[\(\[ ]#{Regexp.quote(path)}[ \)\]]/)

          match.sub(/%w[\(\[]/, '\0' + path + " ")
        end
      end
    end

    def die(message = nil)
      message = message.sub(/^/, "ERROR: ") if message && !message.start_with?(/error/i)

      raise Thor::Error, message
    end

    def read_system_time_zone_name
      return unless File.symlink?("/etc/localtime")

      File.readlink("/etc/localtime")[%r{zoneinfo/(.+)$}, 1]
    end
  end
end
