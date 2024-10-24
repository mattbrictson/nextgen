# frozen_string_literal: true

say_git "Install erb_lint"
install_gem "erb_lint", group: :development, require: false
binstub "erb_lint"
template ".erb_lint.yml.tt"

say_git "Add erb_lint to default rake task"
copy_file "lib/tasks/erb_lint.rake"
add_lint_task "erb_lint"

say_git "Auto-correct any existing issues"
run "bin/erb_lint --lint-all -a", capture: true
