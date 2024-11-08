# frozen_string_literal: true

say_git "Install the annotaterb gem"
install_gem "annotaterb", group: :development

say_git "Run the annotaterb installer"
generate "annotate_rb:install"
