say_git "Install the vite_rails gem"
install_gem "vite_rails", version: "~> 3.0"

say_git "Move asset pipeline files into app/frontend"
remove_file "app/assets/stylesheets/application.css"
remove_file "app/javascript/application.js"
move "app/javascript", "app/frontend"
empty_directory "app/frontend"
move "app/assets/images", "app/frontend/images"
move "app/assets/stylesheets", "app/frontend/stylesheets"
remove_dir "app/assets"
inject_into_class "config/application.rb", "Application", <<-RUBY
  # Prevents Rails from trying to eager-load the contents of app/frontend
  config.javascript_path = "frontend"

RUBY

say_git "Run the vite installer"
FileUtils.touch "yarn.lock"
bundle_command "exec vite install"
gsub_file "app/views/layouts/application.html.erb",
  /vite_javascript_tag 'application' %>/,
  'vite_javascript_tag "application", "data-turbo-track": "reload" %>'

say_git "Replace vite-plugin-ruby with vite-plugin-rails"
add_yarn_packages "rollup@^4.2.0", "vite-plugin-rails"
remove_yarn_package "vite-plugin-ruby"
gsub_file "vite.config.ts", "import RubyPlugin from 'vite-plugin-ruby'", 'import ViteRails from "vite-plugin-rails"'
gsub_file "vite.config.ts", /^\s*?RubyPlugin\(\)/, <<~TYPESCRIPT.gsub(/^/, "    ").rstrip
  ViteRails({
    envVars: { RAILS_ENV: "development" },
    envOptions: { defineOn: "import.meta.env" },
    fullReload: {
      additionalPaths: [],
    },
  })
TYPESCRIPT

say_git "Move vite package from devDependencies to dependencies"
if (vite_version = File.read("package.json")[/"vite":\s*"(.+?)"/, 1])
  remove_yarn_package "vite", capture: true
  add_yarn_package "vite@#{vite_version}"
end

say_git "Install autoprefixer"
add_yarn_packages "postcss@^8.4.24", "autoprefixer@^10.4.14"
copy_file "postcss.config.cjs"

say_git "Disable autoBuild in test environment"
gsub_file "config/vite.json", /("test": \{.+?"autoBuild":\s*)true/m, '\1false'
copy_test_support_file "vite.rb"

say_git "Install modern-normalize and base stylesheets"
add_yarn_package "modern-normalize@^2.0.0"
copy_file "app/frontend/stylesheets/index.css"
copy_file "app/frontend/stylesheets/base.css"
copy_file "app/frontend/stylesheets/reset.css"

say_git "Configure turbo/stimulus"
package_json = File.read("package.json")
if package_json.match?(%r{@hotwired/turbo-rails})
  prepend_to_file "app/frontend/entrypoints/application.js", <<~JS
    import "@hotwired/turbo-rails";
  JS
end
if package_json.match?(%r{@hotwired/stimulus})
  add_yarn_package "stimulus-vite-helpers"
  copy_file "app/frontend/controllers/index.js", force: true
  prepend_to_file "app/frontend/entrypoints/application.js", <<~JS
    import "~/controllers";
  JS
end
prepend_to_file "app/frontend/entrypoints/application.js", <<~JS
  import "~/stylesheets/index.css";
JS

say_git "Add InlineSvgHelper"
if File.read("config/application.rb").match?(/^\s*config\.autoload_lib/)
  copy_file "lib/vite_inline_svg_file_loader.rb"
else
  empty_directory "app/lib"
  copy_file "lib/vite_inline_svg_file_loader.rb", "app/lib/vite_inline_svg_file_loader.rb"
end
copy_file "app/helpers/inline_svg_helper.rb"
copy_file "app/frontend/images/example.svg"
# TODO: rspec support
copy_file "test/helpers/inline_svg_helper_test.rb" if minitest?

say_git "Add a `yarn start` script"
start = "concurrently -i -k --kill-others-on-fail -p none 'RUBY_DEBUG_OPEN=true bin/rails s' 'bin/vite dev'"
add_package_json_script start: start
add_yarn_package "concurrently", dev: true
gsub_file "README.md", %r{bin/rails s(erver)?}, "yarn start"
gsub_file "bin/setup", %r{bin/rails s(erver)?}, "yarn start"
remove_file "Procfile.dev"

say_git "Remove jsbundling-rails"
remove_gem "jsbundling-rails"

say_git "Remove sprockets"
remove_file "config/initializers/assets.rb"
comment_lines "config/environments/development.rb", /^\s*config\.assets\./
comment_lines "config/environments/production.rb", /^\s*config\.assets\./
gsub_file "app/views/layouts/application.html.erb", /^.*<%= stylesheet_link_tag.*$/, ""
remove_gem "sprockets-rails"
