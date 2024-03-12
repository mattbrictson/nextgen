say_git "Add improved bin/setup script"
copy_file "bin/setup", mode: :preserve, force: true

say_git "Specify 2-space indent and other general editor settings"
copy_file ".editorconfig"
copy_file ".prettierrc.cjs"

say_git "Generate documentation"
postgres = File.read("Gemfile").match?(/^\s*gem ['"]pg['"]/)
template "README.md.tt", force: true, context: binding
copy_file "DEPLOYMENT.md"

say_git "Create a Procfile"
template "Procfile.tt"

say_git "Set up default rake task"
test_task = "test:all" if minitest?
append_to_file "Rakefile", <<~RUBY

  Rake::Task[:default].prerequisites.clear if Rake::Task.task_defined?(:default)

  desc "Run all checks"
  task default: %w[#{test_task}] do
    Thor::Base.shell.new.say_status :OK, "All checks passed!"
  end
RUBY

if File.exist?("test/application_system_test_case.rb")
  say_git "Configure system tests"
  copy_test_support_file "capybara.rb.tt"
  copy_file "test/application_system_test_case.rb", force: true
end

if File.exist?(".ruby-version") && File.read(".ruby-version").match?(/\A\d+\.\d+.\d+.\s*\z/m)
  say_git "DRY up Gemfile and .ruby-version file"
  replacement = 'ruby Pathname.new(__dir__).join(".ruby-version").read.strip'
  gsub_file "Gemfile", /^ruby "\d.*"$/, replacement
end

if File.exist?("app/views/layouts/application.html.erb")
  say_git "Improve title and meta information for HTML layout"
  gsub_file "app/views/layouts/application.html.erb", "<html>", '<html lang="en">'
  gsub_file "app/views/layouts/application.html.erb", %r{^\s*<title>.*</title>}, <<~ERB.gsub(/^/, "    ").rstrip
    <title><%= content_for?(:title) ? strip_tags(yield(:title)) : #{app_const_base.titleize.inspect} %></title>
    <meta name="apple-mobile-web-app-title" content="#{app_const_base.titleize}">
  ERB
end

say_git "Disable legacy javascript and stylesheet generators"
copy_file "config/initializers/generators.rb"

say_git "Allow force_ssl to be controlled via env var"
uncomment_lines "config/environments/production.rb", "config.force_ssl = true"
gsub_file "config/environments/production.rb",
  "config.force_ssl = true",
  'config.force_ssl = ENV["RAILS_DISABLE_SSL"].blank?'

if File.exist?("config/database.yml")
  say_git "Create initial schema.rb"
  rails_command "db:prepare"
end
