module Nextgen
  module ThorExtensions
    def self.extended(base)
      super
      base.check_unknown_options!
    end

    def start(given_args = ARGV, config = {})
      config[:shell] ||= Thor::Base.shell.new
      handle_help_switches(given_args) do |args|
        dispatch(nil, args, nil, config)
      end
    rescue Exception => e # rubocop:disable Lint/RescueException
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
      case error
      when Errno::EPIPE
        # Ignore
      when Thor::Error, Interrupt
        raise unless config.fetch(:exit_on_failure, true)

        config[:shell]&.say_error(error.message, :red)
        exit(false)
      else
        raise
      end
    end
  end
end
