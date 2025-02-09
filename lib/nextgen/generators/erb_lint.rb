# frozen_string_literal: true

say_git "Install erb_lint"
install_gem "erb_lint", group: :development, require: false
binstub "erb_lint"
template ".erb_lint.yml.tt"

say_git "Add erb_lint to default rake task"
copy_file "lib/tasks/erb_lint.rake"
add_lint_task "erb_lint"

if File.exist?(".github/workflows/ci.yml")
  say_git "Add erb_lint job to CI workflow"
  inject_into_file ".github/workflows/ci.yml", <<-YAML, after: /^jobs:\n/
  erb_lint:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Lint ERB with erb_lint
        run: bin/erb_lint --lint-all

  YAML
end

say_git "Auto-correct any existing issues"
run "bin/erb_lint --lint-all -a", capture: true
