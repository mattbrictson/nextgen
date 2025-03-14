# frozen_string_literal: true

say_git "Install rubocop gems"
remove_gem "rubocop-rails-omakase"
gemfile = File.read("Gemfile")
plugins = []
plugins << "capybara" if gemfile.match?(/^\s*gem ['"]capybara['"]/)
plugins << "factory_bot" if gemfile.match?(/^\s*gem ['"]factory_bot/)
plugins << "minitest" if minitest?
plugins << "performance"
plugins << "rails"
rubocop_gems = [
  "rubocop",
  *plugins.sort.map { "rubocop-#{_1}" }
]
install_gems(*rubocop_gems.reverse, group: :development, require: false)
binstub "rubocop" unless File.exist?("bin/rubocop")

say_git "Replace .rubocop.yml"
template ".rubocop.yml", context: binding, force: true

if File.exist?(".erb_lint.yml")
  say_git "Regenerate .erb_lint.yml with rubocop support"
  template ".erb_lint.yml", force: true
end

say_git "Add rubocop to default rake task"
copy_file "lib/tasks/rubocop.rake"
add_lint_task "rubocop", fix: "rubocop:autocorrect_all"
inject_into_file "README.md", <<~MARKDOWN, after: /rake fix\n```\n/

  > [!WARNING]
  > A small number of Rubocop's auto-corrections are considered "unsafe" and may
  > occasionally produce incorrect results. After running `fix`, you should
  > review the changes and make sure the code still works as intended.
MARKDOWN

say_git "Auto-correct any existing issues"
uncomment_lines "config/environments/development.rb", /apply_rubocop_autocorrect_after_generate!/
run "bin/rubocop -A --fail-level F", capture: true
