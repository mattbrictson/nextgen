# frozen_string_literal: true

require "rails/version"

module Nextgen
  module RailsCommand
    class << self
      def run(*args, raise_on_error: true)
        command = "rails", "_#{::Rails.version}_", *args
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
