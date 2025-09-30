# frozen_string_literal: true

say_git "Install eslint"
add_js_packages(
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
template "lib/tasks/eslint.rake.tt"
add_lint_task "eslint"

if File.exist?(".github/workflows/ci.yml")
  say_git "Add eslint job to CI workflow"
  node_spec = File.exist?(".node-version") ? 'node-version-file: ".node-version"' : 'node-version: "lts/*"'
  inject_into_file ".github/workflows/ci.yml", <<-YAML, after: /^jobs:\n/
  eslint:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v5

      - name: Set up Node
        uses: actions/setup-node@v5
        with:
          #{node_spec}
          cache: #{js_package_manager}

      - name: Install #{js_package_manager} packages
        run: npx --yes ci

      - name: Lint JavaScript files with eslint
        run: #{js_package_manager} run lint:js

  YAML
end

say_git "Auto-correct any existing issues"
run "#{js_package_manager} run fix:js", capture: true
