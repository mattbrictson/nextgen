# frozen_string_literal: true

say_git "Install stylelint"
add_yarn_packages(
  "stylelint",
  "stylelint-config-standard",
  "stylelint-declaration-strict-value",
  "stylelint-prettier",
  "prettier",
  "npm-run-all",
  dev: true
)
add_package_json_scripts(
  "lint:css": "stylelint 'app/{components,frontend,assets/stylesheets}/**/*.css'",
  "fix:css": "npm run -- lint:css --fix",
  lint: "npm-run-all lint:**",
  fix: "npm-run-all fix:**"
)
copy_file ".stylelintrc.js"

say_git "Add stylelint to default rake task"
copy_file "lib/tasks/stylelint.rake"
add_lint_task "stylelint"

say_git "Auto-correct any existing issues"
run "yarn fix:css", capture: true
