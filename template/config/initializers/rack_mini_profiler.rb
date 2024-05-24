# frozen_string_literal: true

return unless defined?(Rack::MiniProfiler)

# https://github.com/MiniProfiler/rack-mini-profiler#configuration-options
Rack::MiniProfiler.config.enable_hotwire_turbo_drive_support = true
