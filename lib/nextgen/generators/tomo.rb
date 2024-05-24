# frozen_string_literal: true

say_git "Install the tomo gem in the :development group, with a binstub"
install_gem "tomo", version: "~> 1.18", group: :development, require: false
binstub "tomo"

say_git "Initialize the tomo config file"
if File.exist?(".tomo/config.rb")
  say_status :skip, ".tomo/config.rb exists", :blue
else
  bundle_command! "exec tomo init"
end
