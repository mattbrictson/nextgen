# frozen_string_literal: true

say_git "Install erb_lint"
install_gem "erb_lint", group: :development, require: false
binstub "erb_lint"
template ".erb-lint.yml.tt"

say_git "Add erblint to default rake task"
copy_file "lib/tasks/erblint.rake"
add_lint_task "erblint"

say_git "Auto-correct any existing issues"
run "bin/erblint --lint-all -a", capture: true
