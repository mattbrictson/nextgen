# frozen_string_literal: true

return unless Gem.loaded_specs.key?("rubocop")

require "rubocop/rake_task"
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options.push "-c", ".rubocop.yml"
end
