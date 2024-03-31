# Compile assets once at the start of system testing
ActiveSupport.on_load(:action_dispatch_system_test_case) do
  unless ViteRuby.config.auto_build
    millis = Benchmark.ms { ViteRuby.commands.build }
    puts format("Built Vite assets (%.1fms)", millis)
  end
end
