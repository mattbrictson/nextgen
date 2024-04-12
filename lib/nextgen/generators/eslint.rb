say_git "Install eslint"
add_yarn_packages(
  "@eslint/js",
  "eslint@^9",
  "eslint-config-prettier",
  "eslint-formatter-compact",
  "eslint-plugin-prettier",
  "prettier",
  "npm-run-all",
  "@types/eslint",
  dev: true
)
add_package_json_scripts(
  "lint:js": "eslint 'app/{assets,components,frontend,javascript}/**/*.{cjs,js,jsx,ts,tsx}'",
  "fix:js": "npm run -- lint:js --fix",
  lint: "npm-run-all lint:**",
  fix: "npm-run-all fix:**"
)
copy_file "eslint.config.js"

say_git "Add eslint to default rake task"
copy_file "lib/tasks/eslint.rake"
add_lint_task "eslint"

say_git "Auto-correct any existing issues"
run "yarn fix:js", capture: true
