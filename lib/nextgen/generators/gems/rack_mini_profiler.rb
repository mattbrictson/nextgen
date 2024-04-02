install_gem "rack-mini-profiler", group: :development
copy_file "config/initializers/rack_mini_profiler.rb" if File.read("Gemfile").match?(/^\s*gem ['"]turbo-rails['"]/)
