say_git "Install rubocop gems"
gemfile = File.read("Gemfile")
plugins = []
plugins << "capybara" if gemfile.match?(/^\s*gem ['"]capybara['"]/)
plugins << "factory_bot" if gemfile.match?(/^\s*gem ['"]factory_bot/)
plugins << "minitest" if minitest?
plugins << "performance"
plugins << "rails"
install_gem("rubocop-rails", version: ">= 2.22.0", group: :development, require: false)
install_gems(*plugins.map { "rubocop-#{_1}" }, "rubocop", group: :development, require: false)
binstub "rubocop"

say_git "Generate .rubocop.yml"
template ".rubocop.yml", context: binding

if File.exist?(".erb-lint.yml")
  say_git "Regenerate .erb-lint.yml with rubocop support"
  template ".erb-lint.yml", force: true
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
run "bin/rubocop -A --fail-level F", capture: true
