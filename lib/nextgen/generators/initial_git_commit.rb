# frozen_string_literal: true

commit_msg = "tmp/initial_nextgen_commit"
return unless git_working? && File.exist?(commit_msg)

gitignore "node_modules/" if Dir.exist?("node_modules")
git_commit_all(File.read(commit_msg))
