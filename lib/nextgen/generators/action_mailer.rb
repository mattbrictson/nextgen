# frozen_string_literal: true

copy_test_support_file "mailer.rb"
if minitest?
  empty_directory_with_keep_file "test/mailers"
elsif rspec?
  empty_directory_with_keep_file "spec/mailers"
end
