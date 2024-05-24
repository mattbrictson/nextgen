# frozen_string_literal: true

require "rails/version"

module Nextgen
  module Rails
    class << self
      def version
        ::Rails.version
      end

      def edge_branch
        if version.match?(/[a-z]/i)
          "main"
        else
          version[/^\d+\.\d+/].tr(".", "-") + "-stable"
        end
      end

      def run(*args, raise_on_error: true)
        command = "rails", *args
        say_status :run, *command.join(" ")
        with_original_bundler_env do
          system(*command, exception: raise_on_error)
        end
      end

      private

      def say_status(...)
        Thor::Base.shell.new.say_status(...)
      end

      def with_original_bundler_env(&)
        return yield unless defined?(Bundler)

        Bundler.with_original_env(&)
      end
    end
  end
end
