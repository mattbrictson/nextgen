# frozen_string_literal: true

install_gem "bundler-audit", group: :development, require: false
binstub "bundler-audit"

if File.exist?(".github/workflows/ci.yml")
  say_git "Add bundle-audit job to CI workflow"
  inject_into_file ".github/workflows/ci.yml", <<-YAML, after: /^jobs:\n/
  scan_gems:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v5

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Scan for security vulnerabilities in Ruby dependencies
        run: bundle exec bundle-audit check --update -v

  YAML
end
