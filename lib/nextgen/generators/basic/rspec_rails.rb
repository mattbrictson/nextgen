say_git "Install the rspec-rails gem"
install_gem "rspec-rails", group: %i[development test]

say_git "Run the rspec installer"
generate "rspec:install"
gitignore "/spec/examples.txt"
binstub "rspec-core"

say_git "Disable auto-generation of routing and view specs"
inject_into_file "config/initializers/generators.rb", <<~RUBY, after: "g.stylesheets false\n"
  g.routing_specs false
  g.view_specs false
RUBY

say_git "Add spec to default rake task"
inject_into_file "Rakefile", "spec", after: /task default: %w\[/

say_git "Enable auto-loading of the spec/support directory"
uncomment_lines("spec/rails_helper.rb", /Dir\[Rails.root.join/)
