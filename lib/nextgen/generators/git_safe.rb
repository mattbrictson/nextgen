# frozen_string_literal: true

if Dir.exist?(".git")
  say_git "Mark project as trusted so bin/ can be added to PATH"
  empty_directory ".git/safe"
end
