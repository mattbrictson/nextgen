# frozen_string_literal: true

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

if File.exist?(".github/workflows/ci.yml")
  say_git "Add eslint job to CI workflow"
  node_spec = File.exist?(".node-version") ? 'node-version-file: ".node-version"' : 'node-version: "lts/*"'
  inject_into_file ".github/workflows/ci.yml", <<~YAML.gsub(/^/, "  "), after: /^jobs:\n/
    eslint:
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

        - name: Lint JavaScript files with eslint
          run: yarn lint:js

  YAML
end

say_git "Auto-correct any existing issues"
run "yarn fix:js", capture: true
