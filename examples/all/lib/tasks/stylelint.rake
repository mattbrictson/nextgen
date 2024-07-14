# frozen_string_literal: true

desc "Run Stylelint"
task :stylelint do
  sh "yarn lint:css"
end

namespace :stylelint do
  desc "Autocorrect Stylelint offenses"
  task :autocorrect do
    sh "yarn fix:css"
  end
end
