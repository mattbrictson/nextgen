module Nextgen
  module Helpers
    private

    def say_banner
      say <<~BANNER
        Welcome to nextgen, the interactive Rails app generator!

        You are about to create a Rails app named "#{cyan(app_name)}" in the following directory:

          #{cyan(app_path)}

        You'll be asked ~10 questions about database, test framework, and other options.
        The standard Rails "omakase" experience will be selected by default.

      BANNER
    end

    def say_summary
      say <<~SUMMARY

        OK! Your Rails app is ready to be created.
        The following options will be passed to `rails new`:

          #{rails_new_args.join("\n  ")}

        The following nextgen enhancements will also be applied in individual git commits via `rails app:template`:

          #{activated_generators.join(", ").scan(/\S.{0,75}(?:,|$)/).join("\n  ")}

      SUMMARY
    end

    def say_node
      say <<~NODE
        Based on the options you selected, your app will require Node and Yarn. For reference, you are using these versions:

          Node: #{capture_version("node")}
          Yarn: #{capture_version("yarn")}

      NODE
    end

    def say_done
      say <<~DONE.gsub(/^/, "  ")


        #{green("Done!")}

        A Rails #{rails_version} app was generated in #{cyan(app_path)}.
        Run #{set_color("bin/setup", :yellow)} in that directory to get started.


      DONE
    end

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

    def activated_generators
      activated = generators.all_active_names
      activated.prepend(job_backend.all_active_names.first) unless job_backend.nil?

      activated.any? ? activated.sort_by(&:downcase) : ["<None>"]
    end

    def write_generators_script(g)
      new_tempfile_path.tap do |location|
        File.write(location, g.to_ruby_script)
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
