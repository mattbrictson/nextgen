# frozen_string_literal: true

say_git "Install shoulda gems"
install_gem "shoulda-context", version: ">= 3.0.0.rc1", group: :test if minitest?
install_gem "shoulda-matchers", group: :test

say_git "Include shoulda methods in tests"
copy_test_support_file "shoulda.rb"
