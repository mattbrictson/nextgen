# frozen_string_literal: true

desc "Run ESLint"
task :eslint do
  sh "yarn lint:js"
end

namespace :eslint do
  desc "Autocorrect ESLint offenses"
  task :autocorrect do
    sh "yarn fix:js"
  end
end
