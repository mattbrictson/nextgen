# frozen_string_literal: true

return unless File.exist?(".github/workflows/ci.yml")

erb = <<~YAML
  test:
    runs-on: ubuntu-latest

    <%- if gems.include?("pg") -%>
    services:
      postgres:
        image: postgres
        env:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: --health-cmd="pg_isready" --health-interval=10s --health-timeout=5s --health-retries=3

    <%- end -%>
    steps:
      <%- if gems.include?("capybara") -%>
      - name: Install packages
        run: sudo apt-get update && sudo apt-get install --no-install-recommends -y google-chrome-stable

      <%- end -%>
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: .ruby-version
          bundler-cache: true

      - name: Run tests
        env:
          RAILS_ENV: test
          <%- if gems.include?("pg") -%>
          DATABASE_URL: postgres://postgres:postgres@localhost:5432
          <%- end -%>
        <%- if File.exist?("config/database.yml") -%>
        run: bundle exec db:test:prepare rspec
        <%- else -%>
        run: bundle exec rspec
        <%- end -%>
      <%- if gems.include?("capybara") -%>

      - name: Keep screenshots from failed system tests
        uses: actions/upload-artifact@v4
        if: failure()
        with:
          name: screenshots
          path: ${{ github.workspace }}/tmp/screenshots
          if-no-files-found: ignore
      <%- end -%>

YAML

require "erb"
gems = File.exist?("Gemfile") ? File.read("Gemfile").scan(/^\s*gem ["'](.+?)["']/).flatten : []
job = ERB.new(erb, trim_mode: "-").result(binding)
inject_into_file ".github/workflows/ci.yml", job.gsub(/^/, "  "), after: /^jobs:\n/
