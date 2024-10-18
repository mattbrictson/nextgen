# frozen_string_literal: true

desc "Run erb_lint"
task :erb_lint do
  sh "bin/erb_lint --lint-all"
end

namespace :erb_lint do
  desc "Autocorrect erb_lint offenses"
  task :autocorrect do
    sh "bin/erb_lint --lint-all -a"
  end
end
