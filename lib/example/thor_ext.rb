module Example
  module ThorExt
    # Configures Thor to behave more like a typical CLI, with better help and error handling.
    #
    # - Passing -h or --help to a command will show help for that command.
    # - Unrecognized options will be treated as errors (instead of being silently ignored).
    # - Error messages will be printed in red to stderr, without stack trace.
    # - Full stack traces can be enabled by setting the VERBOSE environment variable.
    # - Errors will cause Thor to exit with a non-zero status.
    #
    # To take advantage of this behavior, your CLI should subclass Thor and extend this module.
    #
    #   class CLI < Thor
    #     extend ThorExt::Start
    #   end
    #
    # Start your CLI with:
    #
    #   CLI.start
    #
    # In tests, prevent Kernel.exit from being called when an error occurs, like this:
    #
    #   CLI.start(args, exit_on_failure: false)
    #
    module Start
      def self.extended(base)
        super
        base.check_unknown_options!
      end

      def start(given_args=ARGV, config={})
        config[:shell] ||= Thor::Base.shell.new
        handle_help_switches(given_args) do |args|
          dispatch(nil, args, nil, config)
        end
      rescue StandardError => e
        handle_exception_on_start(e, config)
      end

      private

      def handle_help_switches(given_args)
        yield(given_args.dup)
      rescue Thor::UnknownArgumentError => e
        retry_with_args = []

        if given_args.first == "help"
          retry_with_args = ["help"] if given_args.length > 1
        elsif (e.unknown & %w[-h --help]).any?
          retry_with_args = ["help", (given_args - e.unknown).first]
        end
        raise unless retry_with_args.any?

        yield(retry_with_args)
      end

      def handle_exception_on_start(error, config)
        return if error.is_a?(Errno::EPIPE)
        raise if ENV["VERBOSE"] || !config.fetch(:exit_on_failure, true)

        message = error.message.to_s
        message.prepend("[#{error.class}] ") if message.empty? || !error.is_a?(Thor::Error)

        config[:shell]&.say_error(message, :red)
        exit(false)
      end
    end
  end
end
