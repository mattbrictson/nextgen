# frozen_string_literal: true

say_git "Add Node and Yarn prerequisites"
copy_file "package.json" unless File.exist?("package.json")
inject_into_file "README.md", "\n- Node 18 (LTS) or newer\n- Yarn 1.x (classic)", after: /^- Ruby.*$/
inject_into_file "README.md", "\nbrew install node\nbrew install yarn", after: /^brew install rbenv.*$/
gitignore "node_modules/"
