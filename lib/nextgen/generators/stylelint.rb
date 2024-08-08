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

if File.exist?(".github/workflows/ci.yml")
  say_git "Add stylelint job to CI workflow"
  node_spec = File.exist?(".node-version") ? 'node-version-file: ".node-version"' : 'node-version: "lts/*"'
  inject_into_file ".github/workflows/ci.yml", <<-YAML, after: /^jobs:\n/
  stylelint:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          #{node_spec}
          cache: yarn

      - name: Install Yarn packages
        run: npx --yes ci

      - name: Lint CSS files with stylelint
        run: yarn lint:css

  YAML
end

say_git "Auto-correct any existing issues"
run "yarn fix:css", capture: true
