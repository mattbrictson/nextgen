module Nextgen
  module Actions::Bundler
    def binstubs(*gems)
      bundle_command! "binstubs #{gems.join(" ")} --force"
    end
    alias binstub binstubs

    def install_gems(*names, version: nil, group: nil, require: nil)
      gemfile = TidyGemfile.new
      inserted = names.filter do |name|
        if gemfile.include?(name)
          say_status :exist, name, :blue
          false
        else
          say_status :gemfile, [name, version].compact.join(", ")
          gemfile.add(name, version: version, group: group, require: require)
          true
        end
      end
      return if inserted.empty?

      gemfile.save
      cmd = "install"
      cmd << " --quiet" if noisy_bundler_version?
      bundle_command! cmd
    end
    alias install_gem install_gems

    def remove_gem(name)
      gemfile = TidyGemfile.new
      return unless gemfile.include?(name)

      say_status :gemfile, "remove #{name}"
      gemfile.remove(name)
      gemfile.save

      bundle_command! "install", capture: true, verbose: false
    end

    # Similar to from Rails::Generators::AppBase#bundle_command, but raises if the command fails
    def bundle_command!(cmd, verbose: true, capture: false)
      bundler = Gem.bin_path("bundler", "bundle")
      full_command = %("#{Gem.ruby}" "#{bundler}" #{cmd})

      Bundler.with_original_env do
        say_status :bundle, cmd, :green if verbose
        run! full_command, env: {"BUNDLE_IGNORE_MESSAGES" => "1"}, verbose: false, capture: capture
      end
    end

    def bundler_version_satisifed?(spec)
      require "bundler"
      Gem::Requirement.new(spec).satisfied_by?(Gem::Version.new(Bundler::VERSION))
    rescue LoadError
      false
    end

    def noisy_bundler_version?
      bundler_version_satisifed?("< 2.4.17")
    end
  end
end
