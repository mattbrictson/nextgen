# frozen_string_literal: true

return if ViteRuby.config.auto_build

# Compile assets once at the start of testing
require "benchmark"
seconds = Benchmark.realtime { ViteRuby.commands.build }
puts format("Built Vite assets (%.1fms)", seconds * 1_000)
